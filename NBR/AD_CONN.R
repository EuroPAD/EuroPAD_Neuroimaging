rm(list=ls(all=TRUE))

####create AD_CONN####
library(R.matlab)

setwd("/home/radv/llorenzini/my-scratch/dti_connectomes/")
a    <- list.files()

#### IF IS A MAT FILE #####
data <- readMat(a[1])

raw_conn_mat <- data$schaefer100.sift.radius2.count.connectivity
colnames(raw_conn_mat) <- data$schaefer100.region.labels
rownames(raw_conn_mat) <- data$schaefer100.region.labels

coordinates <- which(upper.tri(raw_conn_mat, diag = FALSE), arr.ind=TRUE) #buono

columns <- c()
vector_of_values <- c()
for (n in 1:nrow(coordinates)){
  vector_of_values <- c(vector_of_values, raw_conn_mat[coordinates[n,1],coordinates[n,2]])
  col <- colnames(raw_conn_mat)[coordinates[n,2]]
  col <- gsub(" ", "", col)
  row <- rownames(raw_conn_mat)[coordinates[n,1]]
  row <- gsub(" ", "", row)
  columns <- c(columns, paste0(row, "_to_", col))
}
tmp <- unlist(strsplit(a[1], split="_"))
columns <- c(columns, "subject_id", "session")

#create matrix#
AD_CONN <- matrix(0, ncol=length(columns), nrow=length(a))
colnames(AD_CONN) <- columns
AD_CONN[1, 1:length(vector_of_values)] <- vector_of_values
AD_CONN[1, "subject_id"] <- tmp[1]
AD_CONN[1, "session"] <- tmp[2]

#reiterate through dataset#
for (j in 2:length(a)){
  vector_of_values <- c() 
  data <- readMat(a[j])
  tmp <- unlist(strsplit(a[j], split="_"))
  raw_conn_mat <- data$schaefer100.sift.radius2.count.connectivity
  for (n in 1:nrow(coordinates)){
  vector_of_values <- c(vector_of_values, raw_conn_mat[coordinates[n,1],coordinates[n,2]])
  }
  vector_of_values <- c(vector_of_values, tmp[1], tmp[2])
  AD_CONN[j,] <- vector_of_values
  print(j)
}


#### IF IS A CSV FILE #####

raw_conn_mat <- read.csv(a[1], header = F)
LUT <- read.delim("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaefer2018_100Parcels_7Networks_order.txt", 
                  header = F)
colnames(raw_conn_mat) <- LUT$V2
rownames(raw_conn_mat) <- LUT$V2

coordinates <- which(upper.tri(raw_conn_mat, diag = FALSE), arr.ind=TRUE) #buono

columns <- c()
vector_of_values <- c()
for (n in 1:nrow(coordinates)){
  vector_of_values <- c(vector_of_values, raw_conn_mat[coordinates[n,1],coordinates[n,2]])
  col <- colnames(raw_conn_mat)[coordinates[n,2]]
  col <- gsub(" ", "", col)
  row <- rownames(raw_conn_mat)[coordinates[n,1]]
  row <- gsub(" ", "", row)
  columns <- c(columns, paste0(row, "_to_", col))
}
tmp <- unlist(strsplit(a[1], split="_"))
columns <- c(columns, "subject_id", "session")


#create matrix#
AD_CONN <- matrix(0, ncol=length(columns), nrow=length(a))
colnames(AD_CONN) <- columns
AD_CONN[1, 1:length(vector_of_values)] <- vector_of_values
AD_CONN[1, "subject_id"] <- tmp[1]
AD_CONN[1, "session"] <- tmp[2]

#reiterate through dataset#
for (j in 2:length(a)){
  vector_of_values <- c() 
  raw_conn_mat <- read.csv(a[j], header = F)
  tmp <- unlist(strsplit(a[j], split="_"))
  for (n in 1:nrow(coordinates)){
    vector_of_values <- c(vector_of_values, raw_conn_mat[coordinates[n,1],coordinates[n,2]])
  }
  vector_of_values <- c(vector_of_values, tmp[1], tmp[2])
  AD_CONN[j,] <- vector_of_values
  print(j)
}





write.csv(AD_CONN, "/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data/AD_CONN.csv")

####add demographic and clinical data####
library(dplyr)

setwd("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data/")

AD_CONN<- read.csv("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data/AD_CONN.csv")
demo <- read.csv("v_imi_epadlcs_socio_demographics.csv")
csf <-  read.csv("v_imi_epadlcs_csf.csv")
mrinfo <- read.csv("v_imi_epadlcs_mri_scanner_information.csv")
cdr <- read.csv("v_imi_epadlcs_cdr.csv")
mmse <- read.csv("v_imi_epadlcs_mmse.csv")
apoe <- read.csv("v_imi_epadlcs_apoe.csv")
EPAD_merged <- read.csv("v_imi_epadlcs_radiological_read.csv")
vascular <- read.csv("EPAD_vascular_infos.csv")
translation <-  read.csv("TranslationTable.csv")
cognition <- read.csv("v_imi_epadlcs_rbans.csv")
  
# Clean visual reads variables NAMES 
names(EPAD_merged)[names(EPAD_merged) == "ahmic"] <- "MB_present"
EPAD_merged$MB_present[EPAD_merged$MB_present == ""] <- NA
EPAD_merged$MB_present <- as.factor(EPAD_merged$MB_present)
EPAD_merged$MB_present <- droplevels(EPAD_merged$MB_present)

names(EPAD_merged)[names(EPAD_merged) == "ahmicblc"] <- "MB_BG_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicblu"] <- "MB_BG_<5mm_left_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicbrc"] <- "MB_BG_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimbrc"] <- "MB_BG_5to10mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimbru"] <- "MB_BG_5to10mm_right_uncertain"

names(EPAD_merged)[names(EPAD_merged) == "ahmicclc"] <- "MB_cerebellum_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicclu"] <- "MB_cerebellum_<5mm_left_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmiccrc"] <- "MB_cerebellum_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmiccru"] <- "MB_cerebellum_<5mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimclc"] <- "MB_cerebellum_5to10mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimclu"] <- "MB_cerebellum_5to10mm_left_uncertain"

names(EPAD_merged)[names(EPAD_merged) == "ahmicglc"] <- "MB_cortex_GM/WMjunction_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicglu"] <- "MB_cortex_GM/WMjunction_<5mm_left_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicgrc"] <- "MB_cortex_GM/WMjunction_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicgru"] <- "MB_cortex_GM/WMjunction_<5mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimglc"] <- "MB_cortex_GM/WMjunction_5to10mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimglu"] <- "MB_cortex_GM/WMjunction_5to10mm_left_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimgrc"] <- "MB_cortex_GM/WMjunction_5to10mm_right_certain"

names(EPAD_merged)[names(EPAD_merged) == "ahmicslc"] <- "MB_brainstem_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicsrc"] <- "MB_brainstem_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimsrc"] <- "MB_brainstem_5to10mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimsru"] <- "MB_brainstem_5to10mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicsru"] <- "MB_brainstem_<5mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicslu"] <- "MB_brainstem_<5mm_left_uncertain"

names(EPAD_merged)[names(EPAD_merged) == "ahmictrc"] <- "MB_thalamus_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmictlc"] <- "MB_thalamus_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmictru"] <- "MB_thalamus_<5mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimtrc"] <- "MB_thalamus_5to10mm_right_certain"

names(EPAD_merged)[names(EPAD_merged) == "ahmicwlc"] <- "MB_subcortical_WM_<5mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicwlu"] <- "MB_subcortical_WM_<5mm_left_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicwrc"] <- "MB_subcortical_WM_<5mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmicwru"] <- "MB_subcortical_WM_<5mm_right_uncertain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimwlc"] <- "MB_subcortical_WM_5to10mm_left_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimwrc"] <- "MB_subcortical_WM_5to10mm_right_certain"
names(EPAD_merged)[names(EPAD_merged) == "ahmimwru"] <- "MB_subcortical_WM_5to10mm_right_uncertain"

names(EPAD_merged)[names(EPAD_merged) == "ahswisli"] <- "MB_comments"
names(EPAD_merged)[names(EPAD_merged) == "ahswicom"] <- "MB_T2starSWI_discrepancies"

names(EPAD_merged)[names(EPAD_merged) == "ss"] <- "superficial_siderosis"
EPAD_merged$superficial_siderosis[EPAD_merged$superficial_siderosis == ""] <- NA
EPAD_merged$superficial_siderosis <- as.factor(EPAD_merged$superficial_siderosis)
EPAD_merged$superficial_siderosis <- droplevels(EPAD_merged$superficial_siderosis)

names(EPAD_merged)[names(EPAD_merged)== "fsd"] <- "Fazekas_Scale_Deep"
names(EPAD_merged)[names(EPAD_merged)== "fspv"] <- "Fazekas_Scale_Periventricular"

names(EPAD_merged)[names(EPAD_merged)== "epsbg"] <- "ePVS_BG"
names(EPAD_merged)[names(EPAD_merged)== "epscs"] <- "ePVS_CS"
names(EPAD_merged)[names(EPAD_merged)== "epspm"] <- "ePVS_PM"

dfpheno <- merge(demo, csf, by = "patient_id") #merging the data
vascular <- vascular %>% distinct(patient_id, .keep_all = TRUE)
dfpheno <- merge(dfpheno, vascular, by = "patient_id", all=T)
dfpheno <- merge(dfpheno, apoe, by = c("patient_id", "visit"), all =T)
dfpheno <- merge(dfpheno, EPAD_merged, by = c("patient_id", "visit"))
dfpheno <- merge(dfpheno, cdr, by = c("patient_id", "visit"))
dfpheno <- merge(dfpheno, mmse, by = c("patient_id", "visit"))
dfpheno <- merge(dfpheno, cognition, by = c("patient_id", "visit"))

dfpheno <- merge(dfpheno, mrinfo, by = c("patient_id","visit","date_of_mri"))
dfpheno <- merge(dfpheno, translation, by = "patient_id")
dfpheno$health_identifier <- gsub("-", "EPAD", dfpheno$health_identifier)
colnames(dfpheno)[ncol(dfpheno)] <- "Subjectname"

length(unique(dfpheno$Subjectname))
df <- dfpheno

# Adjust variables => AT status
sum(df$abeta_1_42_result == "", na.rm = T)
sum(is.na(df$abeta_1_42_result))

df$abeta_1_42_result[which(df$abeta_1_42_result == ">1700")] =  "1700"
df$abeta_1_42_result <- as.numeric(df$abeta_1_42_result)

df$Astatus <- ifelse(df$abeta_1_42_result > 1000, "A-", "A+")
df$Astatus <- as.factor(df$Astatus)

df$ptau_result[which(df$ptau_result == "<8")] <- 8
df$ptau_result <- as.numeric(df$ptau_result)

df$Tstatus <- ifelse(df$ptau_result > 27, "T+", "T-")
df$Tstatus <- as.factor(df$Tstatus)

df$ATN <- paste(df$Astatus, df$Tstatus)
df$ATN <- as.factor(df$ATN)

# Amyloid tau ratio
df$ptau_ab42_ratio <- df$ptau_result/df$abeta_1_42_result

# Computing follow-up time
df$visdat_int <- as.Date(df$date_of_mri)

colnames(df) <- make.unique(colnames(df))

df <- df %>% 
  group_by(patient_id) %>%
  mutate( visdat_int_diff_days = as.numeric(difftime(visdat_int, visdat_int[1], units = "days"))) %>%
  ungroup()

df$visdat_int_diff_years <- df$visdat_int_diff_days/365.25 # account for bisestile

df$age_alltp <- df$age_years + df$visdat_int_diff_years

#Adjusting variables
df <- df %>% 
  group_by(patient_id) %>%
  mutate(
    baseline_age = age_years[1], 
    baseline_AT = ATN[1], 
    baseline_AmyStat = Astatus[1],
    apoe_result = apoe_result[1],
    apoe_sample_collected = apoe_sample_collected[1]
  ) %>%
  ungroup()

# Adjust variables => apoe status
df$apoe_status <- 0
table(df$apoe_sample_collected)
df$apoe_sample_collected[df$apoe_sample_collected==""] = "N"
df$apoe_sample_collected[df$apoe_result==""] = "N" #for some subjects they tested apoe (apoe_sample_collected=Y) but the result is not in the file (apoe_result=="")
df$apoe_status <- ifelse(grepl("N", df$apoe_sample_collected), NA, 0)
df$apoe_status <- ifelse(grepl("e4", df$apoe_result), 1, df$apoe_status)
df$apoe_status[which(df$apoe_result == "e4/e4")] <- 2
table(df$apoe_status)

#Fazekas score categories
table(df$Fazekas_Scale_Deep)
table(df$Fazekas_Scale_Periventricular)
df$Fazekas_tot <- (df$Fazekas_Scale_Deep + df$Fazekas_Scale_Periventricular)/2
table(df$Fazekas_tot)
df$Fazekas_class <- ifelse(df$Fazekas_tot > 1, 1, 0)
table(df$Fazekas_class)

#Baseline AT status
df <- df[-c(which(is.na(df$visdat_int_diff_years))),]
df <- df[-c(which(df$baseline_AT == "NA NA")),]
df <- df[-c(which(df$baseline_AT == "NA T-")),]
df <- df[-c(which(df$baseline_AT == "A+ NA")),]
df$baseline_AT <- droplevels(df$baseline_AT)
table(df$baseline_AT)

#Exclude A-T+ 
df <- df[-c(which(df$baseline_AT=="A- T+")),]
df$baseline_AT <- droplevels(df$baseline_AT)
table(df$baseline_AT)

#Adjusting visits numbers
df$visitnumeric <- as.numeric(substr(df$visit, 2, 2))

####merge clinical and mri data ####
AD_CONN <- as.data.frame(AD_CONN)
AD_CONN$patient_id <- substr(AD_CONN$subject_id, 12, 16)
AD_CONN$visitnumeric <- as.numeric(substr(AD_CONN$session, 6, 6)) 
AD_CONN$visitnumeric <- recode(AD_CONN$visitnumeric,'1'='1','2'='3','3' ='4','4' ='5')
df_CONN <- merge(AD_CONN, df, by = c("patient_id","visitnumeric"))

write.csv(df_CONN, "df_CONN.csv")

####EXPLORATORY ANALYSIS ####

library(NBR)
library(lattice)
library(parallel)
df_CONN <- read.csv("df_CONN.csv")

#Adjust variables#
df_CONN$baseline_AT <- as.factor(df_CONN$baseline_AT) 
df_CONN$site_id <- as.factor(df_CONN$site_id)
df_CONN$apoe_status <- as.factor(df_CONN$apoe_status)
df_CONN$apoe_status <- droplevels(df_CONN$apoe_status)
df_CONN$apoe_carrier <- ifelse(grepl("0", df_CONN$apoe_status), 0, 1)
df_CONN$apoe_carrier <- as.factor(df_CONN$apoe_carrier)
df_CONN$V <- as.factor(df_CONN$V)

x <- grep(x = colnames(df_CONN), pattern = "_to_")
conn_columns <- colnames(df_CONN[,x])
df_CONN_select <- df_CONN[,c("patient_id", "visitnumeric", "site_id", "visdat_int_diff_years",
                             "apoe_carrier", "baseline_AT", 
                             "mmse_total", "cdr_global_score",
                             "frs_total_noage", "V", "baseline_age", "sex", 
                             "visdat_int_diff_years", "ptau_result","abeta_1_42_result",
                             "rbans_total_scale", "rbans_sum_of_index",      
                             "rbans_attention_index", "rbans_delayed_memory_index",
                             "rbans_immediate_memory_index", "rbans_language_index",
                             "rbans_visuo_constructional_index", "rbans_coding",
                             "rbans_digit_span", "rbans_figure_copy",
                             "rbans_figure_recall", "rbans_list_learning",
                             "rbans_line_orientation", "rbans_list_recall",
                             "rbans_list_recognition", "rbans_picture_naming",
                             "rbans_semantic_fluency", "rbans_story_memory",
                             "rbans_story_recall", conn_columns)]
#apply log10 to values of SC#
# visualize distribution of data pre and post log trans
df_CONN_select[,conn_columns] <- log10(df_CONN_select[,conn_columns])
df_CONN_select[,conn_columns][ df_CONN_select[,conn_columns]<0 ] <- 0

nnodes <- 100 #extract number of ROI
dim(df_CONN_select) #see dimension of matrix

head(df_CONN_select)[1:8] #see first part of matrix
tail(df_CONN_select)[1:8] #see last part of matrix

tri_pos <- which(upper.tri(matrix(nrow = nnodes, ncol = nnodes)), arr.ind = T)
head(tri_pos)

avg_mx <- matrix(0, nrow = nnodes, ncol = nnodes)

avg_mx[upper.tri(avg_mx)] <- apply(df_CONN_select[,c(conn_columns)], 2, function(x) mean(x, na.rm=TRUE))
avg_mx <- avg_mx + t(avg_mx)
# Set max-absolute value in order to set a color range centered in zero.
flim <- max(abs(avg_mx))
levelplot(avg_mx, main = "Average", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))

####effect of time####
conn_columns_numeric <- grep(x = colnames(df_CONN_select), pattern = "_to_")
before <- Sys.time()
nbr_result_t3 <- nbr_lme(net=df_CONN_select[,conn_columns], nnodes=152, 
             idata=df_CONN_select[,-conn_columns_numeric], 
             mod="~ sex+baseline_age+visdat_int_diff_years+site_id",
             rdm ="~1+visdat_int_diff_years|patient_id",
             alternative = "two.sided",
             diag = FALSE, nperm = 5, thrP = NULL, thrT = 3,
             cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)
show(nbr_result_t3$fwe)
nbr_result_t3$components$visdat_int_diff_years

edge_mat <- array(0, dim(avg_mx))
edge_mat[nbr_result$components$`visdat_int_diff_years`[,2:3]] <- nbr_result$components$`visdat_int_diff_years`[,5]
edge_mat <- edge_mat + t(edge_mat)
flim <- max(abs(edge_mat))
levelplot(edge_mat, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))

####effect of amyloid####
df_CONN_select_amyloid <- df_CONN_select[!is.na(df_CONN_select$abeta_1_42_result),]
conn_columns_numeric <- grep(x = colnames(df_CONN_select_amyloid), pattern = "_to_")
before <- Sys.time()
nbr_result_amyloid_t3 <- nbr_lme(net=df_CONN_select_amyloid[,conn_columns], nnodes=152, 
                      idata=df_CONN_select_amyloid[,-conn_columns_numeric], 
                      mod="~ sex+baseline_age+visdat_int_diff_years+site_id+abeta_1_42_result",
                      rdm ="~1+visdat_int_diff_years|patient_id",
                      alternative = "two.sided",
                      diag = FALSE, nperm = 5, thrP = NULL, thrT = 3,
                      cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)
show(nbr_result_amyloid_t3$fwe)
nbr_result_amyloid_t3$components$abeta_1_42_result

edge_mat_amy <- array(0, dim(avg_mx))
edge_mat_amy[nbr_result_amyloid_t3$components$`visdat_int_diff_years`[,2:3]] <- nbr_result_amyloid_t3$components$`visdat_int_diff_years`[,5]
edge_mat_amy <- edge_mat_amy + t(edge_mat_amy)
flim <- max(abs(edge_mat_amy))
levelplot(edge_mat_amy, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))

####effect of ptau####
df_CONN_select_ptau <- df_CONN_select[!is.na(df_CONN_select$ptau_result),]
conn_columns_numeric <- grep(x = colnames(df_CONN_select_ptau), pattern = "_to_")
before <- Sys.time()
nbr_result_ptau_t3 <- nbr_lme(net=df_CONN_select_ptau[,conn_columns], nnodes=152, 
                                 idata=df_CONN_select_ptau[,-conn_columns_numeric], 
                                 mod="~ sex+baseline_age+visdat_int_diff_years+site_id+ptau_result",
                                 rdm ="~1+visdat_int_diff_years|patient_id",
                                 alternative = "two.sided",
                                 diag = FALSE, nperm = 5, thrP = NULL, thrT = 3,
                                 cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)
show(nbr_result_ptau_t3$fwe)
nbr_result_ptau_t3$components$ptau_result

edge_mat_tau <- array(0, dim(avg_mx))
edge_mat_tau[nbr_result_ptau_t3$components$`ptau_result`[,2:3]] <- nbr_result_ptau_t3$components$`ptau_result`[,5]
edge_mat_tau <- edge_mat_tau + t(edge_mat_tau)
flim <- max(abs(edge_mat_tau))
levelplot(edge_mat_tau, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))

####effect of cdr####
conn_columns_numeric <- grep(x = colnames(df_CONN_select), pattern = "_to_")
before <- Sys.time()
nbr_result_cdr_t3 <- nbr_lme(net=df_CONN_select[,conn_columns], nnodes=152, 
                              idata=df_CONN_select[,-conn_columns_numeric], 
                              mod="~ sex+baseline_age+visdat_int_diff_years+site_id+cdr_global_score",
                              rdm ="~1+visdat_int_diff_years|patient_id",
                              alternative = "two.sided",
                              diag = FALSE, nperm = 5, thrP = NULL, thrT = 3,
                              cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)
show(nbr_result_cdr_t3$fwe)
nbr_result_cdr_t3$components$cdr_global_score_result

edge_mat_cdr <- array(0, dim(avg_mx))
edge_mat_cdr[nbr_result_cdr_t3$components$`cdr_global_score_result`[,2:3]] <- nbr_result_cdr_t3$components$`cdr_global_score_result`[,5]
edge_mat_cdr <- edge_mat_cdr + t(edge_mat_cdr)
flim <- max(abs(edge_mat_cdr))
levelplot(edge_mat_cdr, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))

####effect of global_rbans####
df_CONN_select_rbans <- df_CONN_select[!is.na(df_CONN_select$rbans_total_scale),]
conn_columns_numeric <- grep(x = colnames(df_CONN_select_rbans), pattern = "_to_")
before <- Sys.time()
nbr_result_rbans_t3 <- nbr_lme(net=df_CONN_select_rbans[,conn_columns], nnodes=152, 
                             idata=df_CONN_select_rbans[,-conn_columns_numeric], 
                             mod="~ sex+baseline_age+visdat_int_diff_years+site_id+rbans_total_scale",
                             rdm ="~1+visdat_int_diff_years|patient_id",
                             alternative = "two.sided",
                             diag = FALSE, nperm = 5, thrP = NULL, thrT = 3,
                             cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)
show(nbr_result_rbans_t3$fwe)
nbr_result_rbans_t3$components$rbans_total_scale

edge_mat_rbans <- array(0, dim(avg_mx))
edge_mat_rbans[nbr_result_rbans_t3$components$`rbans_total_scale`[,2:3]] <- nbr_result_rbans_t3$components$`rbans_total_scale`[,5]
edge_mat_rbans <- edge_mat_rbans + t(edge_mat_rbans)
flim <- max(abs(edge_mat_rbans))
levelplot(edge_mat_rbans, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(-flim, flim, length.out = 100))




####linear mixed effect model####
# set.seed(18900217)
# before <- Sys.time()
# library(nlme)
# library(parallel)
# nbr_result <- nbr_lme_aov(
#   net = voles[,-(1:3)],
#   nnodes = 16,
#   idata = voles[,1:3],
#   nperm = 1000,
#   nudist = T,
#   mod = "~ Session*Sex",
#   rdm = "~ 1+Session|id",
#   cores = detectCores(),
#   na.action = na.exclude
# )
# after <- Sys.time()
# show(after-before)

####unused lines####
# columns <- c()
# for (n in 2:152 & i %in% 1:152) {
#   vector <- labels[n:152]
#   for (vec in vector) {
#   lista <- paste0(vec, labels[n-1], collapse="_to_")
#   columns <- append(columns, lista)
#   }
# }