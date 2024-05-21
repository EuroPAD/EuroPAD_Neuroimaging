##### Visualize Output ######
library(NBR)
library(lattice)
library(parallel)
setwd("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data/")

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


nbr_result_p001$fwe


#### EFFECT OF AMYLOID ####
#BINARIZED
edge_mat_amy <- array(0, dim(avg_mx))
edge_mat_amy[nbr_result_p001$components$abeta_1_42_result[,2:3]] <- 1
edge_mat_amy <- edge_mat_amy + t(edge_mat_amy)
flim <- max(abs(edge_mat_amy))
levelplot(edge_mat_amy, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(0, flim, length.out = 100))

#### EFFECT OF TAU ####
#BINARIZED
edge_mat_tau <- array(0, dim(avg_mx))
edge_mat_tau[nbr_result_p001$components$ptau_result[,2:3]] <- 1
edge_mat_tau <- edge_mat_tau + t(edge_mat_tau)
flim <- max(abs(edge_mat_tau))
levelplot(edge_mat_tau, col.regions = rev(heat.colors(100)),
          main = "Component", ylab = "ROI", xlab = "ROI",
          at = seq(0, flim, length.out = 100))


# # Continuous
# edge_mat[nbr_result_p001$components$ptau_result[,2:3]]<- nbr_result_p001$components$ptau_result[,5]
# edge_mat <- edge_mat + t(edge_mat)
# flim <- max(edge_mat)
# llim <- min(edge_mat)
# levelplot(edge_mat, col.regions = rev(heat.colors(100)),
#           main = "Component", ylab = "ROI", xlab = "ROI",
#           at = seq(llim, flim, length.out = 100))

library(brainGraph)
LUT=read.csv("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv")

mnicoord <- LUT[, c(3,4,5)]


LUT$network <- ""
LUT$size <- 1
LUT$regioname <- ""

for (i in c(1: nrow(LUT))){
  LUT$network[i] <- strsplit(LUT$ROI.Name[i], "_")[[1]][3]
  LUT$regioname[i] <- strsplit(LUT$ROI.Name[i], "_")[[1]][4]
}


LUT$network <- as.numeric(as.factor(LUT$network))
nodesfile <- LUT[,c(3:8)]


#### Annotate results
sig_connec_amy <- as.data.frame(matrix("", nrow(nbr_result_p001$components$abeta_1_42_result), 2))
colnames(sig_connec_amy) <- c("from", "to")
sig_connec_amy$from <- LUT$ROI.Name[nbr_result_p001$components$abeta_1_42_result[,2]]
sig_connec_amy$to <- LUT$ROI.Name[nbr_result_p001$components$abeta_1_42_result[,3]]

sig_connec_tau <- as.data.frame(matrix("", nrow(nbr_result_p001$components$ptau_result), 2))
colnames(sig_connec_tau) <- c("from", "to")
sig_connec_tau$from <- LUT$ROI.Name[nbr_result_p001$components$ptau_result[,2]]
sig_connec_tau$to <- LUT$ROI.Name[nbr_result_p001$components$ptau_result[,3]]


setwd("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/NBR/nodes_files")
write.table(nodesfile, file="schaef_100_nodes.node", row.names = F, col.names = F)

write.table(edge_mat_amy, file="amy_effect.edge", row.names = F, col.names = F)
write.table(edge_mat_tau, file="tau_effect.edge", row.names = F, col.names = F)

# getwd()
# mat <- as.matrix(edge_mat)
# graphmat <- graph_from_adjacency_matrix(mat)
# atlas <- 'Schaefer2018_100Parcels_7Networks'
# make_brainGraph(mat, atlas)
# write_brainnet(mnicoord, graphmat, "/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/data")



library(pheatmap)

paletteLength <- 50
myColor <- colorRampPalette(c("blue", "white", "red"))(paletteLength)
# length(breaks) == length(paletteLength) + 1
# use floor and ceiling to deal with even/odd length pallettelengths
myBreaks <- c(seq(min(edge_mat), 0, length.out=ceiling(paletteLength/2) + 1), 
              seq(max(edge_mat)/paletteLength, max(edge_mat), length.out=floor(paletteLength/2)))

# Plot the heatmap
edge_mat_df <- as.data.frame(edge_mat)
annotation_row <- as.data.frame(matrix("", nrow(LUT), 1))
rownames(annotation_row) <- rownames(edge_mat_df)
colnames(annotation_row) <- "network"
annotation_row$network <- as.factor(LUT$network)
pheatmap(edge_mat, color=myColor, breaks=myBreaks,
         cluster_cols = F, cluster_rows = F, annotation_row = annotation_row)





nrow(as.data.frame(LUT$network))

annotation_row = data.frame(
  GeneClass = factor(rep(c("Path1", "Path2", "Path3"), c(50, 40, 10)))
)
rownames(annotation_row) = rownames(edge_mat_df)

