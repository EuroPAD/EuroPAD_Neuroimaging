########### Load libraries and atlas ########################################
## clear workspace
rm(list=ls(all=TRUE))

## load libraries
library(dplyr)
library(NetworkToolbox)
library(ggplot2)
library(pheatmap)
library(igraph)

## Set working directory
setwd("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/amyloid_spread_prithvi")

## Add labels and rename rows and columns
label <- read.csv("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/amyloid_spread_prithvi/code/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_1mm.Centroid_RAS.csv")
label <- label[,2]

########### Process average functional connectome ##########################

## Read the average functional connectome
avg_func_connectome_path <- "path/to/average_functional_connectome.csv"  # Replace with actual path
fmri <- read.csv(avg_func_connectome_path, header=FALSE)

## Preprocess functional connectome
fmri[fmri<0] <- fmri[fmri<0] * -1  # Take absolute values of negative correlations
fmri <- as.matrix(fmri)

## Apply threshold
threshold = 0.2 
threshold_matrix <- quantile(fmri, threshold)
fmri[fmri < threshold_matrix] <- 0

## Rename rows and columns
colnames(fmri) <- label
rownames(fmri) <- label

## Create graph object for functional connectome
g_fmri <- graph_from_adjacency_matrix(fmri, mode = "undirected", weighted = TRUE)
V(g_fmri)$name <- colnames(fmri)

## Compute shortest path lengths for functional connectome
fmri_path_lengths <- distances(g_fmri, mode = "all", weights = E(g_fmri)$weight)

## Create a data frame with all pairwise distances
fmri_distances <- as.data.frame(fmri_path_lengths)

## Save the functional path length matrix
write.csv(fmri_distances, "avg_functional_shortest_pathlengths.csv")

########### Process average structural connectome ##########################

## Read the average structural connectome
avg_struct_connectome_path <- "path/to/average_structural_connectome.csv"  # Replace with actual path
dwi <- read.csv(avg_struct_connectome_path, header=FALSE)

## Preprocess structural connectome
dwi <- log(dwi)  # Log transformation of structural connectivity matrix
dwi[dwi < 1] <- 0  # Set values less than 1 to zero

## Rename rows and columns
colnames(dwi) <- label
rownames(dwi) <- label

## Create graph object for structural connectome
g_dwi <- graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
V(g_dwi)$name <- colnames(dwi)

## Compute shortest path lengths for structural connectome
dwi_path_lengths <- distances(g_dwi, mode = "all", weights = E(g_dwi)$weight)

## Create a data frame with all pairwise distances
dwi_distances <- as.data.frame(dwi_path_lengths)

## Save the structural path length matrix
write.csv(dwi_distances, "avg_structural_shortest_pathlengths.csv")