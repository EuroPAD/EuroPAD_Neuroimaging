####FIXEL-WISE STATISTICS####
rm(list = ls())
library(ModelArray)
setwd("/scratch/radv/mtranfa/Fixelwise/")
datadir="/scratch/radv/mtranfa/Fixelwise/"
EPAD_fixel <- read.csv(file.path(datadir, "EPAD_vIMI_baseline_fixels_harm_norm.csv"))

#remove selected WM tracts#
EPAD_fixel <- EPAD_fixel %>% 
  dplyr::select(-contains(c("SCP_", "ICP_", "MCP_"))) %>% 
  dplyr::select(-starts_with(c("CC_fd", "CC_fc", "CC_fdc", "ST_", "wb_", 
                               "FX_fd", "FX_fc", "FX_fdc", "T_", "POPT_",
                               "FPT")))

fd_regions <- colnames(EPAD_fixel)[endsWith(colnames(EPAD_fixel), "_fd_combat")]
fc_regions <- colnames(EPAD_fixel)[endsWith(colnames(EPAD_fixel), "_fc_combat")]
fdc_regions <- colnames(EPAD_fixel)[endsWith(colnames(EPAD_fixel), "_fdc_combat")]
tracts <- "all_included_bundles"

prsofint <- c("prs_apoe", "prs_noapoe", colnames(EPAD_fixel)[endsWith(colnames(EPAD_fixel), "BA")])

EPAD_fixel$site_id <- as.factor(EPAD_fixel$site_id)
EPAD_fixel$AT <- as.factor(EPAD_fixel$AT)
table(EPAD_fixel$AT)

#remove A-T+
EPAD_fixel <- EPAD_fixel[-c(which(EPAD_fixel$AT == "A-T+")),]
EPAD_fixel$AT <- droplevels(EPAD_fixel$AT)

#create AT stage continuous variable#
EPAD_fixel$AT_num <- ifelse(EPAD_fixel$AT == "A-T-", 0, ifelse(EPAD_fixel$AT == "A+T-", 1,2))
EPAD_fixel$AT_num <- as.numeric(EPAD_fixel$AT_num)

#make list for confixel
EPAD_fixel$file_name <- paste0(EPAD_fixel$subject_id, ".mif")

for (tract in tracts){
  print(tract)
  
  # filename of fixel-wise data (.h5 file):
  h5_path <- paste0("/scratch/radv/mtranfa/Fixelwise/", tract,  "_fdc_smooth.h5")

# create a ModelArray-class object:
# vector_of_analyses <- paste0(prsofint, "_results_lm") 
# modelarray <- ModelArray(h5_path, scalar_types = c("fdc_smooth"), vector_of_analyses)
modelarray <- ModelArray(h5_path, scalar_types = c("fdc_smooth"))

scalars(modelarray)[["fdc_smooth"]]

# filename of example fixel-wise data (.h5 file):
csv <- paste0(tract,  "_fdc_smooth_cohort.csv")
phenotypes <- read.csv(file.path(datadir, csv))

EPAD_fixel$source_file <- paste0("fdc_smooth/",tract, "/",EPAD_fixel$subject_id, ".mif")
EPAD_fixel$scalar_name <- "fdc_smooth"
df_model <- EPAD_fixel[, c("source_file", "scalar_name", prsofint, "prs_onlyapoe", "age_tot", "sex", "PC1", "PC2",
                           "PC3", "PC4", "PC5", "AT", "eTIV_combat_log" )]

for (prs in prsofint){
  if (prs == "prs_apoe"){
    formula.lm = as.formula(paste0("fdc_smooth ~" ,prs, "*AT + age_tot + sex + PC1 + PC2 + PC3 + PC4 + PC5 + eTIV_combat_log"))
    mylm <- ModelArray.lm(formula.lm, 
                          modelarray, 
                          df_model, 
                          "fdc_smooth",
                          #element.subset = 1:100,
                          full.outputs = TRUE,
                          var.terms = c("estimate", "statistic", "p.value"),
                          var.model = c("adj.r.squared", "p.value"),
                          correct.p.value.terms = c("fdr", "bonferroni"),
                          correct.p.value.model = c("fdr", "bonferroni"),
                          num.subj.lthr.abs = 50,
                          num.subj.lthr.rel = 0.2,
                          verbose = F,
                          pbar = TRUE,
                          n_cores = 8)
    analysis_name = paste0(prs, "_results_lm")
    writeResults(h5_path, df.output = mylm, analysis_name = analysis_name)
    
  } else {
    formula.lm = as.formula(paste0("fdc_smooth ~" ,prs, "*AT + prs_onlyapoe + age_tot + sex + PC1 + PC2 + PC3 + PC4 + PC5 + eTIV_combat_log")) 
    mylm <- ModelArray.lm(formula.lm, 
                          modelarray, 
                          df_model, 
                          "fdc_smooth",
                          #element.subset = 1:100,
                          full.outputs = TRUE,
                          var.terms = c("estimate", "statistic", "p.value"),
                          var.model = c("adj.r.squared", "p.value"),
                          correct.p.value.terms = c("fdr", "bonferroni"),
                          correct.p.value.model = c("fdr", "bonferroni"),
                          num.subj.lthr.abs = 50,
                          num.subj.lthr.rel = 0.2,
                          verbose = F,
                          pbar = TRUE,
                          n_cores = 8)
    analysis_name = paste0(prs, "_results_lm")
    writeResults(h5_path, df.output = mylm, analysis_name = analysis_name)
  }
}
}
