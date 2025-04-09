###################################################################
# Brain Network Analysis for Structural and Functional Connectomes
# This script computes various graph theory metrics 
# Schaefer 100 regions - Yeo 17 labels
###################################################################
##### Setup and Initialize output dfs #####
## Clear workspace
rm(list=ls(all=TRUE))

## Load required libraries
library(dplyr)
library(NetworkToolbox)
library(ggplot2)
library(pheatmap)
library(igraph)

##### Initialize Data Structures ######
## Import matrices
## Set working directory
setwd("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives") #disc matrices directory
#savepath <- "/home/radv/ftreves/my-scratch/"

## Import brain region labels (YEO 17 NETWORKS LABELS)
label <- read.csv("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_francesca/atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_1mm.Centroid_RAS.csv")
label <- label[,2]
#label <- gsub("17Networks_", "", label)

## Initialize dataframes to store results
# Vector representations of connectivity matrices
all_func_vector <- data.frame()
all_dwi_vector <- data.frame()

# Functional connectivity metrics
func_results_betweenness_thr <- data.frame()
func_results_clustering_thr <- data.frame()
func_results_global_clustering_thr <- data.frame()
func_results_local_efficiency_thr <- data.frame()
func_results_global_efficiency_thr <- data.frame()
func_results_nodal_efficiency_thr <- data.frame()
func_results_pathlength_thr <- data.frame()
func_results_degree_thr <- data.frame()
func_results_weighted_degree_thr <- data.frame()
func_results_global_properties <- data.frame()
#func_results_smallworldness_thr <- data.frame()
func_results_shortest_paths_thr <- data.frame()

# Structural connectivity metrics
str_results_betweenness_log_transf <- data.frame()
str_results_clustering_log_transf <- data.frame()
str_results_global_clustering_log_transf <- data.frame()
str_results_local_efficiency_log_transf <- data.frame()
str_results_global_efficiency_log_transf <- data.frame()
str_results_nodal_efficiency_log_transf <- data.frame()
str_results_pathlength_log_transf <- data.frame()
str_results_degree_log_transf <- data.frame()
str_results_weighted_degree_log_transf <- data.frame()
str_results_global_properties <- data.frame()
#str_results_smallworldness_log_transf <- data.frame()
str_results_shortest_paths_log_transf <- data.frame()

# Combined results
results_global_clustering <- data.frame()
results_efficiency <- data.frame()
results_pathlength <- data.frame()
merged_df <- data.frame()
merged_df_str <- data.frame()

##### Loop through each subject directory in fmriprep-v23.0.1 ##########################
## Read list of functional connectivity matrices
file_paths <- readLines("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1/connectome_list2.txt")
file_paths <- data.frame(file_paths)

total_files <- nrow(file_paths)
## Process each functional connectivity matrix
for (i in 1:total_files) {
  conn <- file_paths[i,1]
  
  # Read and preprocess matrix
  fmri <- read.csv(conn, header=F)
  
  # Print progress
  cat(sprintf("Processing file %d/%d...\n", i, total_files))
  
  
  #print(fmri)
  fmri[fmri<0] <- fmri[fmri<0]* -1
  fmri <- as.matrix(fmri)
  
  # Apply threshold to create sparse matrix
  threshold = 0.2 
  threshold_matrix <- quantile(fmri, threshold)
  fmri[fmri < threshold_matrix] <- 0
  
  ## Rename rows and columns with brain region labels
  colnames(fmri) <- label
  rownames(fmri) <- label
  
  ## Vectorize the matrix
  ## Check which cells in the matrix are in the upper triangle
  func_coordinates <- which(upper.tri(fmri, diag = FALSE), arr.ind=TRUE) 
  
  ## For loop to vectorize the dwi matrix
  func_columns <- c()
  func_vector_of_values <- c()
  
  # Extract values and create connection labels
  for (n in 1:nrow(func_coordinates)){
    func_vector_of_values <- c(func_vector_of_values, fmri[func_coordinates[n,1],func_coordinates[n,2]])
    func_col <- colnames(fmri)[func_coordinates[n,2]] ###adapt this part to store names of regions and use it to populate your new vectorized matrix
    func_row <- rownames(fmri)[func_coordinates[n,1]]
    func_columns <- c(func_columns, paste0(func_row, "_to_", func_col))
  }
  
  func_vector <- data.frame(rbind(func_columns,func_vector_of_values))
  
  ## Create a dataframe with the functional vectorized values and rename the columns
  func_list <- list(func_vector_of_values)
  func_vector <- as.data.frame(do.call(rbind, func_list))
  colnames(func_vector) <- paste0("func_",func_columns)
  
  ## Extract subjectID and session number from the name of the file
  func_split <-  strsplit(basename(conn), "_")[[1]]
  func_split <- data.frame(func_split)
  SubjectID <- func_split[1,1]
  session <- func_split[2,1]
  
  # Add subject information and combine with main dataframe
  func_vector <- cbind(session, func_vector)
  func_vector <- cbind(SubjectID,func_vector)
  all_func_vector <- rbind(all_func_vector, func_vector)
  
  ###################### CALCULATE GRAPH PROPERTIES ##########################
  
  ## INTEGRATION MEASURES ##

  # ## Path Length - average shortest path between all pairs of nodes  
  # #fmri_list <- list(fmri)
  # func_path <- igraph::graph_from_data_frame(fmri)
  # func_pathlength <- igraph::mean_distance(func_path, directed=FALSE, unconnected=TRUE)

  ## Shortest path lengths (across each pair of nodes)
  g_fmri <- graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE)
  V(g_fmri)$name <- colnames(fmri)
  fmri_shortest_path_lengths <- igraph::distances(g_fmri, mode = "all", weights = E(g_fmri)$weight)
  
  # Prepare the data for storage
  fmri_distances <- as.vector(fmri_shortest_path_lengths)
  fmri_colnames <- as.vector(outer(label, label, FUN = function(f, l) paste0(f, "_to_", l)))
  
  # Create a data frame for this subject
  fmri_path_row <- data.frame(
    SubjectID = func_split[1,1],
    session = func_split[2,1],
    t(fmri_distances)
  )
  
  # Set column names
  colnames(fmri_path_row)[-c(1, 2)] <- fmri_colnames
  
  # ## Betweenness Centrality - measure of node importance in network communication
  # func_bw <- NetworkToolbox::betweenness(fmri, weighted=T)
  # 
  # ## Global Efficiency - measure of network integration
  # glob_eff <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE) # Convert matrix in a graph object
  # global_func_efficiency <- igraph::global_efficiency(glob_eff, directed = F)
  # 
  # ## Nodal Efficiency - efficiency of information transfer for each node
  # func_nodal_graph <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE)
  # nodal_func_efficiency <- brainGraph::efficiency(func_nodal_graph, type = "nodal")
  # 
  # ## Degree - number of connections per node
  # fgraph <- graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE, diag = FALSE)
  # func_degree <- degree(fgraph)
  # 
  # ## Weighted Degree - sum of connection weights for each node
  # func_weighted_degree <- strength(fgraph, mode = "all", weights = E(fgraph)$weight)
  # 
  # 
  # ## SEGREGATION MEASURES ##
  # 
  # ## Local Clustering Coefficient - measure of node-level segregation
  # func_clust <- clustcoeff(as.matrix(fmri))
  # func_local_clustering_coeff <- func_clust$CCi
  # 
  # ## Global Clustering Coefficient - measure of network-level segregation
  # func_GLB_clust <- clustcoeff(as.matrix(fmri))
  # func_global_clustering_coeff <- func_GLB_clust$CC
  # 
  # ## Local Efficiency - measure of local information transfer
  # loc_eff <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE)
  # local_func_efficiency <- igraph::local_efficiency(loc_eff)
  # 
  # ## SMALLWORLDNESS (error message troublshoot; decrease iterations?)
  # #sw_func <- smallworldness(fmri, method="HG")
  # 
  # 
  # ## STORE RESULTS IN DATAFRAMES ##
  # 
  # ## Betweenness centrality
  # func_subject_betweenness <- data.frame(
  #   SubjectID = func_split[1,], # extract subjectID
  #   session = func_split[2,],  # extract session number
  #   func_bw = t(as.data.frame(func_bw))
  # )
  # colnames(func_subject_betweenness)[3:ncol(func_subject_betweenness)] <- c(paste0("func_betweenness_", label))
  # func_results_betweenness_thr <- rbind(func_results_betweenness_thr, func_subject_betweenness)
  # rownames(func_results_betweenness_thr) <- NULL
  # 
  # ## Local clustering coefficient
  # func_subject_clustering <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   func_local_clustering_coeff= t(as.data.frame(func_local_clustering_coeff))
  # )
  # colnames(func_subject_clustering)[3:ncol(func_subject_clustering)] <- c(paste0("func_clustering_coeff_", label))
  # func_results_clustering_thr <- rbind(func_results_clustering_thr, func_subject_clustering)
  # rownames(func_results_clustering_thr) <- NULL
  # 
  # ## Global clustering coefficient
  # func_global_subject_clustering <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   func_global_clustering_coeff = t(as.data.frame(func_global_clustering_coeff))
  # )
  # func_results_global_clustering_thr <- rbind(func_results_global_clustering_thr, func_global_subject_clustering)
  # rownames(func_results_global_clustering_thr) <- NULL
  # 
  # ## Global efficiency
  # func_subject_efficiency <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],  #extract session number
  #   global_func_efficiency = global_func_efficiency
  # )
  # func_results_global_efficiency_thr <- rbind(func_results_global_efficiency_thr, func_subject_efficiency)
  # 
  # ## Local efficiency
  # func_subject_local_efficiency <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   local_func_efficiency= t(as.data.frame(local_func_efficiency))
  # )
  # colnames(func_subject_local_efficiency)[3:ncol(func_subject_local_efficiency)] <- c(paste0("func_local_eff_", label))
  # func_results_local_efficiency_thr <- rbind(func_results_local_efficiency_thr, func_subject_local_efficiency)
  # rownames(func_results_local_efficiency_thr) <- NULL
  # 
  # 
  # ## Nodal efficiency
  # func_subject_nodal_efficiency <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   func_nodal_efficiency = t(as.data.frame(nodal_func_efficiency))
  # )
  # colnames(func_subject_nodal_efficiency)[3:ncol(func_subject_nodal_efficiency)] <- c(paste0("nodal_func_eff_", label))
  # func_results_nodal_efficiency_thr <- rbind(func_results_nodal_efficiency_thr, func_subject_nodal_efficiency)
  # rownames(func_results_nodal_efficiency_thr) <- NULL
  # 
  # ## Degree
  # func_subject_degree <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   func_degree = t(as.data.frame(func_degree))  
  # )
  # colnames(func_subject_degree)[3:ncol(func_subject_degree)] <- c(paste0("func_degree_", label))
  # func_results_degree_thr <- rbind(func_results_degree_thr, func_subject_degree)
  # rownames(func_results_degree_thr) <- NULL
  # 
  # ## Weighted Degree
  # func_subject_w_degree <- data.frame(
  #   SubjectID = func_split[1,],
  #   session = func_split[2,],
  #   func_weighted_degree = t(as.data.frame(func_weighted_degree))  
  # )
  # colnames(func_subject_w_degree)[3:ncol(func_subject_w_degree)] <- c(paste0("func_weighted_degree_", label))
  # func_results_weighted_degree_thr <- rbind(func_results_weighted_degree_thr, func_subject_w_degree)
  # rownames(func_results_weighted_degree_thr) <- NULL
  # 
  # ## Smallworldness
  # # func_sw_all_subjects <- data.frame(
  # # SubjectID =func_split[1,],
  # # session = func_split[2,], 
  # # sw_func = sw_func$swm)
  # # func_results_smallworldness_thr <- rbind(func_results_smallworldness_thr, func_sw_all_subjects)
  # # rownames(func_results_smallworldness_thr) <- NULL
  # 
  # ## Pathlength
  # func_pathlength_all_subjects <- data.frame(
  #   SubjectID = unc_split[1,],
  #   session = func_split[2,],
  #   func_pathlength = func_pathlength)
  # func_results_pathlength_thr <- rbind(func_results_pathlength_thr, func_pathlength_all_subjects)
  # rownames(func_results_pathlength_thr) <- NULL
  # 
  ## Shortest path lenghts
  func_results_shortest_paths_thr <- rbind(func_results_shortest_paths_thr, fmri_path_row)
  
}

##### Loop through each subject directory in qsirecon ##########################
## Read list of structural connectivity matrices
file_paths <- readLines("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0/all_17networks_sift_SC_list.txt")
file_paths <- data.frame(file_paths)

total_files <- nrow(file_paths)
## Process each structural connectivity matrix
for (i in 1:total_files){
  conn <- file_paths[i,1]
  
  # Read and preprocess matrix
  dwi <- read.csv(conn, header=F)
  #print(dwi)
  
  # Print progress
  cat(sprintf("Processing file %d/%d...\n", i, total_files))
  
  # Log-transform structural connectivity values and threshold
  dwi <- log(dwi) #log transformation of structural connectivity matrix
  dwi[dwi < 1] <- 0 #set negative numbers to zero
  #pheatmap(dwi, filename = paste0("dwi_pheatmap_", subject_dir, ".jpg",  cluster_rows = FALSE, cluster_cols = FALSE, show_colnames = FALSE))
  
  # Rename rows and columns
  colnames(dwi) <- label
  rownames(dwi) <- label
  
  ## Vectorize the matrix
  # Check which cells in the matrix are in the upper triangle
  dwi_coordinates <- which(upper.tri(dwi, diag = FALSE), arr.ind=TRUE) 
  
  # For loop to vectorize the dwi matrix
  dwi_columns <- c()
  dwi_vector_of_values <- c()
  
  # Extract values and create connection labels
  for (n in 1:nrow(dwi_coordinates)){
    dwi_vector_of_values <- c(dwi_vector_of_values, dwi[dwi_coordinates[n,1],dwi_coordinates[n,2]])
    dwi_col <- colnames(dwi)[dwi_coordinates[n,2]] ###adapt this part to store names of regions and use it to populate your new vectorized matrix
    dwi_row <- rownames(dwi)[dwi_coordinates[n,1]]
    dwi_columns <- c(dwi_columns, paste0(dwi_row, "_to_", dwi_col))
  }
  dwi_vector <- data.frame(rbind(dwi_columns,dwi_vector_of_values))
  
  ## Create a dataframe with the dwi vectorized values and rename the columns
  dwi_list <- list(dwi_vector_of_values)
  dwi_vector <- as.data.frame(do.call(rbind, dwi_list))
  colnames(dwi_vector) <- paste0("str_", dwi_columns)
  
  ## Extract subjectID and session number from the name of the file 
  dwi_split <-  strsplit(basename(conn), "_")[[1]]
  dwi_split <- data.frame(dwi_split)
  SubjectID <- dwi_split[1,1]
  session <- dwi_split[2,1]
  
  # Add subject information and combine with main dataframe
  dwi_vector <- cbind(session, dwi_vector)
  dwi_vector <- cbind(SubjectID,dwi_vector)
  all_dwi_vector <- rbind(all_dwi_vector, dwi_vector)
  
  
  ##################### CALCULATE GRAPH PROPERTIES ##########################
  
  ## INTEGRATION MEASURES ##

  ## Path Length
  str_path <- igraph::graph_from_data_frame(dwi)
  str_pathlength <- igraph::mean_distance(str_path, directed=FALSE, unconnected = TRUE)

  ## Shortest path lengths (across each pair of nodes)
  g_dwi <- graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
  V(g_dwi)$name <- colnames(dwi)
  dwi_shortest_path_lengths <- igraph::distances(g_dwi, mode = "all", weights = E(g_dwi)$weight)
  
  # Prepare the data for storage
  dwi_distances <- as.vector(dwi_shortest_path_lengths)
  dwi_colnames <- as.vector(outer(label, label, FUN = function(f, l) paste0(f, "_to_", l)))
  
  # Create a data frame for this subject
  dwi_path_row <- data.frame(
    SubjectID = dwi_split[1,1],
    session = dwi_split[2,1],
    t(dwi_distances)
  )
  
  # Set column names
  colnames(dwi_path_row)[-c(1, 2)] <- dwi_colnames
  
  ## Betweenness Centrality
  str_bw <- NetworkToolbox::betweenness(dwi, weighted=T)

  ## Global Efficiency
  str_eff <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE) # Create graph from matrix dwi
  global_str_efficiency <- igraph::global_efficiency(str_eff, directed = F)

  ## Nodal Efficiency
  str_nodal_graph <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
  nodal_str_efficiency <- brainGraph::efficiency(str_nodal_graph, type = "nodal")
 
  ## Degree
  sgraph <- graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE, diag = FALSE)
  str_degree <- degree(sgraph)
  
  ## Weighted Degree
  str_weighted_degree <- strength(sgraph, mode = "all", weights = E(sgraph)$weight)
  
  
  ## SEGREGATION MEASURES ##

  ## Local Clustering Coefficient
  str_clust <- clustcoeff(as.matrix(dwi)) # Compute local clustering coefficient
  str_local_clustering_coeff <- str_clust$CCi # Extract local clustering coefficient values

  ## Global Clustering Coefficient
  str_GLB_clust<- clustcoeff(as.matrix(dwi)) # Compute global clustering coefficient
  str_global_clustering_coeff <- str_GLB_clust$CC # Extract global clustering coefficient values

  ## Local Efficiency
  loc_eff <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
  local_str_efficiency <- igraph::local_efficiency(loc_eff)

  ## SMALLWORLDNESS (error message troublshoot; decrease iterations?)
  #sw_str <- smallworldness(dwi, method="HG")

  
  ## STORE RESULTS IN DATAFRAMES ##

  ## Betweenness centrality
  str_subject_betweenness <- data.frame(
    SubjectID = dwi_split[1,], # extract subjectID
    session = dwi_split[2,],  # extract session number
    str_bw = t(as.data.frame(str_bw))
  )
  colnames(str_subject_betweenness)[3:ncol(str_subject_betweenness)] <- c(paste0("str_betweenness_", label))
  str_results_betweenness_log_transf <- rbind(str_results_betweenness_log_transf, str_subject_betweenness)
  rownames(str_results_betweenness_log_transf) <- NULL

  ## Local clustering coefficient
  str_subject_clustering <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,], #adjust or mi arrabbio
    str_local_clustering_coeff= t(as.data.frame(str_local_clustering_coeff))
  )
  colnames(str_subject_clustering)[3:ncol(str_subject_clustering)] <- c(paste0("str_clustering_coeff_", label))
  str_results_clustering_log_transf <- rbind(str_results_clustering_log_transf, str_subject_clustering)
  rownames(str_results_clustering_log_transf) <- NULL
  
  ## Global clustering coefficient
  str_global_subject_clustering <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_global_clustering_coeff = t(as.data.frame(str_global_clustering_coeff))
  )
  str_results_global_clustering_log_transf <- rbind(str_results_global_clustering_log_transf, str_global_subject_clustering)
  rownames(str_results_global_clustering_log_transf) <- NULL

  ## Global efficiency
  str_subject_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],  #extract session number
    global_str_efficiency = global_str_efficiency
  )
  str_results_global_efficiency_log_transf <- rbind(str_results_global_efficiency_log_transf, str_subject_efficiency)

  ## Local efficiency
  str_subject_local_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    local_str_efficiency= t(as.data.frame(local_str_efficiency))
  )
  colnames(str_subject_local_efficiency)[3:ncol(str_subject_local_efficiency)] <- c(paste0("str_local_eff_", label))
  str_results_local_efficiency_log_transf <- rbind(str_results_local_efficiency_log_transf, str_subject_local_efficiency)
  rownames(str_results_local_efficiency_log_transf) <- NULL
  
  ## Nodal efficiency
  str_subject_nodal_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_nodal_efficiency = t(as.data.frame(nodal_str_efficiency))
  )
  colnames(str_subject_nodal_efficiency)[3:ncol(str_subject_nodal_efficiency)] <- c(paste0("nodal_str_eff_", label))
  str_results_nodal_efficiency_log_transf <- rbind(str_results_nodal_efficiency_log_transf, str_subject_nodal_efficiency)
  rownames(str_results_nodal_efficiency_log_transf) <- NULL

  ## Degree
  str_subject_degree <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_degree = t(as.data.frame(str_degree))  
  )
  colnames(str_subject_degree)[3:ncol(str_subject_degree)] <- c(paste0("str_degree_", label))
  str_results_degree_log_transf <- rbind(str_results_degree_log_transf, str_subject_degree)
  rownames(str_results_degree_log_transf) <- NULL
  
  ## Weighted Degree
  str_subject_w_degree <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_weighted_degree = t(as.data.frame(str_weighted_degree))  
  )
  colnames(str_subject_w_degree)[3:ncol(str_subject_w_degree)] <- c(paste0("str_weighted_degree_", label))
  str_results_weighted_degree_log_transf <- rbind(str_results_weighted_degree_log_transf, str_subject_w_degree)
  rownames(str_results_weighted_degree_log_transf) <- NULL
  
  ## Smallworldness
  # str_sw_all_subjects <- data.frame(
  # SubjectID =dwi_split[1,],
  # session = dwi_split[2,], 
  # sw_str = sw_str$swm,
  # str_results_smallworldness_log_transf <- rbind(str_results_smallworldness_log_transf, str_sw_all_subjects)
  # rownames(str_results_smallworldness_log_transf) <- NULL

  ## Pathlength
  str_pathlength_all_subjects <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_pathlength = str_pathlength
  )
  str_results_pathlength_log_transf <- rbind(str_results_pathlength_log_transf, str_pathlength_all_subjects)
  rownames(str_results_pathlength_log_transf) <- NULL
  
  ## Shortest path lenghts
  str_results_shortest_paths_log_transf <- rbind(str_results_shortest_paths_log_transf, dwi_path_row)
}

##### Merge and Save Results #######
## Merge functional and structural global metrics
results_global_clustering <- merge(func_results_global_clustering_thr, str_results_global_clustering_log_transf, by = c("SubjectID", "session"))
results_efficiency <- merge(func_results_global_efficiency_thr, str_results_global_efficiency_log_transf, by = c("SubjectID", "session"))
#results_smallworldness <- merge(func_results_smallworldness_thr, str_results_smallworldness_log_transf, by = c("SubjectID", "session"))
results_pathlength <- merge(func_results_pathlength_thr, str_results_pathlength_log_transf, by = c("SubjectID", "session"))

## Create combined global properties dataframes
## Functional global properties 
merged_df_func <- merge(func_results_global_efficiency_thr,func_results_global_clustering_thr, by = c("SubjectID", "session"))
func_results_global_properties <- merge(merged_df_func, func_results_pathlength_thr, by = c("SubjectID", "session"))

## Structural global properties 
merged_df_str <- merge(str_results_global_efficiency_log_transf, str_results_global_clustering_log_transf,  by = c("SubjectID", "session"))
str_results_global_properties <- merge(merged_df_str, str_results_pathlength_log_transf, by = c("SubjectID", "session"))

## Define output paths
output_path_global_func <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/graph_properties/Functional_networks/global_properties/"
output_path_global_str <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/graph_properties/Structural_networks/global_properties/"
dir.create(output_path_global_func, recursive = TRUE, showWarnings = FALSE)
dir.create(output_path_global_str, recursive = TRUE, showWarnings = FALSE)

output_path_local_func <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/graph_properties/Functional_networks/local_properties/"
output_path_local_str <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/graph_properties/Structural_networks/local_properties/"
dir.create(output_path_local_func, recursive = TRUE, showWarnings = FALSE)
dir.create(output_path_local_str, recursive = TRUE, showWarnings = FALSE)

## Save all results as CSV files

# Functional metrics
write.csv(func_results_betweenness_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_betweenness_thr.csv"), row.names = FALSE)
write.csv(func_results_clustering_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_clustering_thr.csv"), row.names = FALSE)
write.csv(func_results_local_efficiency_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_local_efficiency_thr.csv"), row.names = FALSE)
write.csv(func_results_nodal_efficiency_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_nodal_efficiency_thr.csv"), row.names = FALSE)
write.csv(func_results_degree_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_degree_thr.csv"), row.names = FALSE)
write.csv(func_results_global_properties, paste0(output_path_global_func, "func_Schaefer_100_Yeo17_results_all_global_properties.csv"), row.names = FALSE)
write.csv(func_results_global_clustering_thr, paste0(output_path_global_func, "func_Schaefer_100_Yeo17_results_global_clustering_thr.csv"), row.names = FALSE)
write.csv(func_results_global_efficiency_thr, paste0(output_path_global_func, "func_Schaefer_100_Yeo17_results_global_efficiency_thr.csv"), row.names = FALSE)
write.csv(func_results_pathlength_thr, paste0(output_path_global_func, "func_Schaefer_100_Yeo17_results_pathlength_thr.csv"), row.names = FALSE)
write.csv(func_results_weighted_degree_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_weighted_degree_thr.csv"), row.names = FALSE)
write.csv(func_results_shortest_paths_thr, paste0(output_path_local_func, "func_Schaefer_100_Yeo17_results_shortest_path_lengths_thr.csv"), row.names = FALSE)

# Structural metrics
write.csv(str_results_betweenness_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_betweenness_log_transf.csv"), row.names = FALSE)
write.csv(str_results_clustering_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_clustering_log_transf.csv"), row.names = FALSE)
write.csv(str_results_local_efficiency_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_local_efficiency_log_transf.csv"), row.names = FALSE)
write.csv(str_results_nodal_efficiency_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_nodal_efficiency_log_transf.csv"), row.names = FALSE)
write.csv(str_results_degree_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_degree_log_transf.csv"), row.names = FALSE)
write.csv(str_results_global_properties, paste0(output_path_global_str, "str_Schaefer_100_Yeo17_results_all_global_properties.csv"), row.names = FALSE)
write.csv(str_results_global_clustering_log_transf, paste0(output_path_global_str, "str_Schaefer_100_Yeo17_results_global_clustering_log_transf.csv"), row.names = FALSE)
write.csv(str_results_global_efficiency_log_transf, paste0(output_path_global_str, "str_Schaefer_100_Yeo17_results_global_efficiency_log_transf.csv"), row.names = FALSE)
write.csv(str_results_pathlength_log_transf, paste0(output_path_global_str, "str_Schaefer_100_Yeo17_results_pathlength_log_transf.csv"), row.names = FALSE)
write.csv(str_results_weighted_degree_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_weighted_degree_log_transf.csv"), row.names = FALSE)
write.csv(str_results_shortest_paths_log_transf, paste0(output_path_local_str, "str_Schaefer_100_Yeo17_results_shortest_path_lengths_log_transf.csv"), row.names = FALSE)
