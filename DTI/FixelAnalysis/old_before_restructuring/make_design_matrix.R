library(dplyr)

fixel_folder <- "/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels"
files_list <- read.delim(file.path(fixel_folder,"template/files.txt"), header = FALSE)

setwd("/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/data/")
df <- read.csv("EPAD_vIMI_baseline_fixels_harm.csv")

#Exclude A-T+ 
df$baseline_AT <- df$AT
df <- df[-c(which(df$baseline_AT=="A-T+")),]
df$baseline_AT <- as.factor(df$baseline_AT)
df$baseline_AT <- droplevels(df$baseline_AT)
table(df$baseline_AT)

#Adjusting visits numbers
# df$visitnumeric <- as.numeric(substr(df$visit, 2, 2))
# 
# #Keep only first visit 
# df <- df[c(which(df$visitnumeric == 1)),]

#Merge df and files_list
files_list$patient_id <- substring(files_list$V1, 12, 16)
df <- merge(files_list, df, by = "patient_id", all.y = T)

#Create design matrix and order rows based on files_list
design_matrix <- as.data.frame(matrix(0, nrow(df), 6)) 
colnames(design_matrix) <- c("patient_id", "intercept", "ATstatus", "age", "sex", "PRS")
design_matrix$patient_id <- df$patient_id
design_matrix$intercept <- 1
for (name in design_matrix$patient_id){ 
# design_matrix$Astatus[c(which(design_matrix$patient_id == name))] <- ifelse(df$Astatus[c(which(df$patient_id == name))] == "A+", 1, -1) 
#design_matrix$Aminus[c(which(design_matrix$patient_id == name))] <- ifelse(df$Astatus[c(which(df$patient_id == name))] == "A-", 1, 0) 
 design_matrix$ATstatus[which(design_matrix$patient_id == name)] <- ifelse(df$AT[which(df$patient_id == name)] == "A-T-", 0,
                                                                              ifelse(df$AT[which(df$patient_id == name)] == "A+T-", 1, 2))
 
  # ifelse(df$AT[which(df$patient_id == name)] == "A-T-", 0, ifelse(df$AT[c(which(df$patient_id == name))] == "A+T-", 1, 2)) 
 #design_matrix$Aminus[c(which(design_matrix$patient_id == name))] <- ifelse(df$Astatus[c(which(df$patient_id == name))] == "A-", 1, 0) 
 design_matrix$sex[which(design_matrix$patient_id == name)] <- ifelse(df$sex[which(df$patient_id == name)] == "f", 1, 0)
 design_matrix$age[which(design_matrix$patient_id == name)] <- df$age_tot[which(df$patient_id == name)]
 design_matrix$PRS[which(design_matrix$patient_id == name)] <- df$Pt_5e.08bellenguez_apoe[which(df$patient_id == name)]
}

design_matrix <- design_matrix[ order(match(design_matrix$patient_id, files_list$patient_id)), ]

#Create a new files_list filtering out subjects that are missing in the design matrix
files_list <- merge(files_list, design_matrix, by = "patient_id" )

#Create definitive files and 
design_matrix <- files_list[,-c(1,2)] 
design_matrix$age <- scale(design_matrix$age) #age normalisation 
files_list_def <- as.data.frame(files_list[,-c(1,3,4,5,6,7)])
contrast_matrix <- as.data.frame(matrix(0, 1, ncol(design_matrix)))
colnames(contrast_matrix) <- colnames(design_matrix)
positive_contrast <- contrast_matrix
positive_contrast[1,]  <- c(0,0,0,0,1)

negative_contrast <- contrast_matrix
negative_contrast[1,]  <- c(0,0,0,0,-1)


#Write txt files 
write.table(files_list_def, 
            file = file.path(fixel_folder,"template/files.txt"), 
            col.names = FALSE, 
            row.names = FALSE, 
            quote = FALSE)
write.table(design_matrix, 
            file = file.path(fixel_folder,"template/design_matrix_Pt_5e.08bellenguez_apoe.txt"), 
            col.names = FALSE, 
            row.names = FALSE, 
            quote = FALSE)
write.table(positive_contrast, 
            file = file.path(fixel_folder,"template/positive_contrast_Pt_5e.08bellenguez_apoe.txt"), 
            col.names = FALSE, 
            row.names = FALSE, 
            quote = FALSE)
write.table(negative_contrast, 
            file = file.path(fixel_folder,"template/negative_contrast_Pt_5e.08bellenguez_apoe.txt"), 
            col.names = FALSE, 
            row.names = FALSE, 
            quote = FALSE)

