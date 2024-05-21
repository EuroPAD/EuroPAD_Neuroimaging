####### Run NBR in SCREEN #########
setwd("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data/")

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
df_CONN$abeta_1_42_result <- ifelse(df_CONN$abeta_1_42_comments != "", as.numeric(gsub(".*?([0-9]+).*", "\\1", df_CONN$abeta_1_42_comments)), df_CONN$abeta_1_42_result) 
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

####  RUN MODEL ####
conn_columns_numeric <- grep(x = colnames(df_CONN_select), pattern = "_to_")
before <- Sys.time()
nbr_result_p001 <- nbr_lm(net=df_CONN_select[,conn_columns], nnodes=nnodes, 
                         idata=df_CONN_select[,-conn_columns_numeric], 
                         mod="~ abeta_1_42_result*ptau_result + sex+baseline_age+site_id",
                         alternative = "two.sided",
                         diag = FALSE, nperm = 1000,  thrP = 0.001,
                         cores = 64, nudist = T, expList = NULL, verbose = TRUE)
after <- Sys.time()
show(after-before)


rm(list=setdiff(ls(), "nbr_result_p001"))

save.image("abetaptau_perm1000_p005.RData")


