# HEATMAP creation ----

library(dplyr)
library(tidyr)
library(pheatmap)
library(colorspace)

# adjust paths accordingly
data = read.csv("~/my-scratch/dr_somi/derivatives/melodic_yeo_cc.csv")
atlas_labels = read.csv("~/my-scratch/dr_somi/derivatives/17NetworksOrderedNames.csv")
MELODIC_dim = 19
outputdir = ""

# prepare matrix
data_matrix = pivot_wider(data, names_from = yeo, values_from = fslcc) %>%
  dplyr::select(-melodic)
colnames(data_matrix) = atlas_labels[[2]]
rownames(data_matrix) = c(0:MELODIC_dim)
rownames(data_matrix) = paste0("IC ", rownames(data_matrix))

# create heatmap
pheatmap::pheatmap(data_matrix,
         angle_col = 315,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         border_color = "white",
         row.names = TRUE,
         main = "Correlation matrix Yeo by Melodic IC",
         color = sequential_hcl(100, palette = "Purples3", rev = TRUE, l2 = 100),
         filename = paste0(outputdir,"/heatmap.pdf")
         )

# create binned heatmap
pheatmap::pheatmap(data_matrix,
         angle_col = 315,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         border_color = "white",
         main = "Correlation matrix Yeo by Melodic IC",
         color = sequential_hcl(4, palette = "Purples3", rev = TRUE, l2 = 100),
         filename = paste0(outputdir,"/heatmap_binned.pdf"))