# HEATMAP creation ----

library(dplyr)
library(tidyr)
library(pheatmap)
library(colorspace)

data <- read.csv("~/my-scratch/dr_somi/derivatives/melodic_yeo_cc.csv")

data_matrix = pivot_wider(data, names_from = yeo, values_from = cc) %>%
  select(-melodic)
colnames(data_matrix) = read.csv("~/my-scratch/dr_somi/derivatives/17NetworksOrderedNames.csv")[[2]]
rownames(data_matrix) = c(0:19)
rownames(data_matrix) = paste0("IC ", rownames(data_matrix))

pheatmap(data_matrix,
         angle_col = 315,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         border_color = "white",
         row.names = TRUE,
         main = "Correlation matrix Yeo by Melodic IC",
         color = sequential_hcl(100, palette = "Purples3", rev = TRUE, l2 = 100),
         filename = "~/my-scratch/dr_somi/derivatives/heatmap.pdf"
         )

pheatmap(data_matrix,
         angle_col = 315,
         cluster_rows = FALSE,
         cluster_cols = FALSE,
         border_color = "white",
         main = "Correlation matrix Yeo by Melodic IC",
         color = sequential_hcl(4, palette = "Purples3", rev = TRUE, l2 = 100),
         filename = "~/my-scratch/dr_somi/derivatives/heatmap_tresh.pdf")

