##### Setup and Initialize output dfs #####
## clear workspace
rm(list=ls(all=TRUE))

library(dplyr)
library(NetworkToolbox)
library(ggplot2)
library(pheatmap)
library(igraph)

## Import matrices
## Set working directory
setwd("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives") #disc matrices directory

## Add labels and rename rows and columns
label <- read.csv("../code/multimodal_MRI_processing/multilayer/graph_properties/DK_FSLMNI152_1mm.csv")
label <- label[,2]

# ## Initialize all dataframes for functional and structural connectomes
# all_dwi_vector <- data.frame()
# all_func_vector <- data.frame()
# 
# str_results_betweenness_log_transf <- data.frame()
# func_results_betweenness_thr <- data.frame()
# 
# str_results_clustering_log_transf <- data.frame()
# func_results_clustering_thr <- data.frame()
# 
# results_global_clustering <- data.frame()
# 
# str_results_global_clustering_log_transf <- data.frame()
# func_results_global_clustering_thr <- data.frame()
# 
# results_efficiency <- data.frame()
# 
# str_results_local_efficiency_log_transf <- data.frame()
# str_results_global_efficiency_log_transf <- data.frame()
# 
# func_results_local_efficiency_thr <- data.frame()
# func_results_global_efficiency_thr <- data.frame()
# 
# str_results_nodal_efficiency_log_transf <- data.frame()
# func_results_nodal_efficiency_thr <- data.frame()
# 
# #str_results_smallworldness_log_transf <- data.frame()
# #func_results_smallworldness_thr <- data.frame()
# 
# results_pathlength <- data.frame()
# 
# str_results_pathlength_log_transf <- data.frame()
# func_results_pathlength_thr <- data.frame()
# 
# str_results_degree_log_transf <- data.frame()
# func_results_degree_thr <- data.frame()
# 
# func_results_global_properties <- data.frame()
# merged_df <- data.frame()
# 
# merged_df_str <- data.frame()
# str_results_global_properties <- data.frame()


## Initialize all dataframes for Gray matter networks
gm_vector <- data.frame()
gm_results_betweenness <- data.frame()
gm_results_clustering <- data.frame()
gm_results_global_clustering <- data.frame()
gm_results_efficiency <- data.frame()
gm_results_local_efficiency <- data.frame()
gm_results_global_efficiency <- data.frame()
gm_results_nodal_efficiency <- data.frame()
gm_results_smallworldness <- data.frame()
gm_results_pathlength <- data.frame()
gm_results_degree <- data.frame()
gm_results_global_properties <- data.frame()
gm_results_weighted_degree <- data.frame()


##### Loop through each subject directory in MIND directory (missing node: sub-AMYPAD06010523_ses-000) ######

# Create a dataframe to track error files
error_files <- data.frame(file_path = character(), 
                          error_message = character(),
                          stringsAsFactors = FALSE)

## Read the list of connectome files
file_paths <- readLines("/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1/all_MIND_list.txt")
file_paths <- data.frame(file_paths)

# Take only first 5 connectomes
#file_paths <- file_paths[1:3, ]
#file_paths <- data.frame(file_paths)

# Get total number of files
total_files <- nrow(file_paths)

# Loop through each connectome file
for (i in 1:total_files) {
  conn <- file_paths[i, 1]
  
  # Print progress 
  cat(sprintf("Processing file %d/%d...\n", i, total_files))
  
  # Use tryCatch to handle errors
  tryCatch({
  
  # Read the grey matter network
  gm <- read.csv(conn, header=F)
  
  #print(gm)
  
  # Remove first row and column
  gm <- gm[-1, -1]
  
  # Rename rows and columns
  colnames(gm) <- label
  rownames(gm) <- label
  
  # Vectorize the matrix
  gm_coordinates <- which(upper.tri(gm, diag = FALSE), arr.ind=TRUE)
  
  gm_columns <- c()
  gm_vector_of_values <- c()
  
  for (n in 1:nrow(gm_coordinates)){
    gm_vector_of_values <- c(gm_vector_of_values, gm[gm_coordinates[n,1], gm_coordinates[n,2]])
    gm_col <- colnames(gm)[gm_coordinates[n,2]]
    gm_row <- rownames(gm)[gm_coordinates[n,1]]
    gm_columns <- c(gm_columns, paste0(gm_row, "_to_", gm_col))
  }
  
  # Create dataframe with vectorized values
  gm_list <- list(gm_vector_of_values)
  gm_vector_temp <- as.data.frame(do.call(rbind, gm_list))
  colnames(gm_vector_temp) <- paste0("gm_", gm_columns)
  
  # Extract subject ID and session
  gm_split <- strsplit(basename(conn), "_")[[1]]
  SubjectID <- gm_split[1]
  session <- gm_split[2]
  gm_vector_temp <- cbind(session, gm_vector_temp)
  gm_vector_temp <- cbind(SubjectID, gm_vector_temp)
  gm_vector <- rbind(gm_vector, gm_vector_temp)
  
  
  ########################## GRAPH PROPERTIES ##########################
  
  ## INTEGRATION MEASURES
  
  # Pathlength (check)
  gm_path <- igraph::graph_from_adjacency_matrix(as.matrix(gm), mode="undirected", weighted=TRUE)
  #gm_path <- igraph::graph_from_data_frame(gm)
  gm_pathlength <- igraph::mean_distance(gm_path, directed=FALSE, unconnected=TRUE)
  
  # Betweenness
  gm_matrix <- as.matrix(gm)
  class(gm_matrix) <- "numeric"  # Ensure matrix is treated as numeric\
  gm_bw <- NetworkToolbox::betweenness(gm_matrix, weighted = T)
  
  # Global efficiency
  #global_gm_efficiency <- igraph::global_efficiency(gm_path, directed=F)
  gm_eff <- igraph::graph_from_adjacency_matrix(as.matrix(gm), mode = "undirected", weighted = TRUE) # Create graph from matrix dwi
  global_gm_efficiency <- igraph::global_efficiency(gm_eff, directed = F)
  
  # Nodal efficiency
  #nodal_gm_efficiency <- brainGraph::efficiency(gm_path, type="nodal")
  gm_nodal_graph <- igraph::graph_from_adjacency_matrix(as.matrix(gm), mode = "undirected", weighted = TRUE)
  nodal_gm_efficiency <- brainGraph::efficiency(gm_nodal_graph, type = "nodal")
  
  # Degree (check)
  #gm_degree <- igraph::degree(gm_path)
  gm_degree <- NetworkToolbox::degree(gm_matrix)
  
  # WEIGHTED DEGREE (sum of connection weights)
  gm_weighted_degree <- strength(gm_path, mode = "all", weights = E(gm_path)$weight)
  
  ## SEGREGATION MEASURES
  
  # Local clustering coefficient 
  gm_clust <- clustcoeff(gm_matrix, weighted = TRUE)
  gm_local_clustering_coeff <- gm_clust$CCi
  
  # Global clustering coefficient 
  gm_global_clustering_coeff <- gm_clust$CC
  
  # Local efficiency
  #local_gm_efficiency <- igraph::local_efficiency(gm_path)
  loc_eff <- igraph::graph_from_adjacency_matrix(as.matrix(gm), mode = "undirected", weighted = TRUE)
  local_gm_efficiency <- igraph::local_efficiency(loc_eff)
  
  
  ## CREATE DATAFRAMES FOR RESULTS
  
  # Betweenness centrality
  gm_subject_betweenness <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_bw = t(as.data.frame(gm_bw))
  )
  colnames(gm_subject_betweenness)[3:ncol(gm_subject_betweenness)] <- paste0("gm_betweenness_", label)
  gm_results_betweenness <- rbind(gm_results_betweenness, gm_subject_betweenness)
  rownames(gm_results_betweenness) <- NULL
  
  # Local clustering
  gm_subject_clustering <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_local_clustering_coeff = t(as.data.frame(gm_local_clustering_coeff))
  )
  colnames(gm_subject_clustering)[3:ncol(gm_subject_clustering)] <- paste0("gm_clustering_coeff_", label)
  gm_results_clustering <- rbind(gm_results_clustering, gm_subject_clustering)
  rownames(gm_results_clustering) <- NULL
  
  
  # Global clustering
  gm_global_subject_clustering <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_global_clustering_coeff = gm_global_clustering_coeff
  )
  gm_results_global_clustering <- rbind(gm_results_global_clustering, gm_global_subject_clustering)
  
  # Global efficiency
  gm_subject_efficiency <- data.frame(
    SubjectID = SubjectID,
    session = session,
    global_gm_efficiency = global_gm_efficiency
  )
  gm_results_global_efficiency <- rbind(gm_results_global_efficiency, gm_subject_efficiency)
  
  # Local efficiency
  gm_subject_local_efficiency <- data.frame(
    SubjectID = SubjectID,
    session = session,
    local_gm_efficiency = t(as.data.frame(local_gm_efficiency))
  )
  colnames(gm_subject_local_efficiency)[3:ncol(gm_subject_local_efficiency)] <- paste0("gm_local_efficiency_", label)
  gm_results_local_efficiency <- rbind(gm_results_local_efficiency, gm_subject_local_efficiency)
  rownames(gm_results_local_efficiency) <- NULL
  
  # Nodal efficiency
  gm_subject_nodal_efficiency <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_nodal_efficiency = t(as.data.frame(nodal_gm_efficiency))
  )
  colnames(gm_subject_nodal_efficiency)[3:ncol(gm_subject_nodal_efficiency)] <- paste0("gm_nodal_eff_", label)
  gm_results_nodal_efficiency <- rbind(gm_results_nodal_efficiency, gm_subject_nodal_efficiency)
  rownames(gm_results_nodal_efficiency) <- NULL
  
  # Degree
  gm_subject_degree <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_degree = t(as.data.frame(gm_degree))
  )
  colnames(gm_subject_degree)[3:ncol(gm_subject_degree)] <- paste0("gm_degree_", label)
  gm_results_degree <- rbind(gm_results_degree, gm_subject_degree)
  rownames(gm_results_degree) <- NULL
  
  # Weighted Degree
  gm_subject_weighted_degree <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_degree = t(as.data.frame(gm_weighted_degree))
  )
  colnames(gm_subject_weighted_degree)[3:ncol(gm_subject_weighted_degree)] <- paste0("gm_weighted_degree_", label)
  gm_results_weighted_degree <- rbind(gm_results_weighted_degree, gm_subject_weighted_degree)
  rownames(gm_results_weighted_degree) <- NULL
  
  # Pathlength
  gm_pathlength_subject <- data.frame(
    SubjectID = SubjectID,
    session = session,
    gm_pathlength = gm_pathlength
  )
  gm_results_pathlength <- rbind(gm_results_pathlength, gm_pathlength_subject)
  
  }, error = function(e) {
    # Add error file to the error_files dataframe
    error_files <<- rbind(error_files, data.frame(
      file_path = conn,
      error_message = as.character(e),
      stringsAsFactors = FALSE
    ))
    
    # Print error message to console but continue processing
    cat(sprintf("ERROR in file %s: %s\n", conn, as.character(e)))
  })
}

##### Loop through each subject directory in fmriprep-v23.0.1 ##########################

file_paths <- readLines("/home/radv/ftreves/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1/connectome_list2.txt")
file_paths <- data.frame(file_paths)

for (conn in file_paths[,1]) {
  
  fmri <- read.csv(conn, header=F)
  
  print(fmri)
  
  fmri[fmri<0] <- fmri[fmri<0]* -1
  fmri <- as.matrix(fmri)
  threshold = 0.2 
  threshold_matrix <- quantile(fmri, threshold)
  fmri[fmri < threshold_matrix] <- 0
  
  ## Rename rows and columns
  colnames(fmri) <- label
  rownames(fmri) <- label
  
  ## Vectorize the matrix
  
  ## Check which cells in the matrix are in the upper triangle
  func_coordinates <- which(upper.tri(fmri, diag = FALSE), arr.ind=TRUE) 
  
  ## For loop to vectorize the dwi matrix
  func_columns <- c()
  func_vector_of_values <- c()
  
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
  func_vector <- cbind(session, func_vector)
  func_vector <- cbind(SubjectID,func_vector)
  all_func_vector <- rbind(all_func_vector, func_vector)
  
  ########################## GRAPH PROPERTIES ##########################
  
  ## INTEGRATION MEASURES

  ##PATHLENGTH
  #fmri_list <- list(fmri)
  func_path <- igraph::graph_from_data_frame(fmri)
  func_pathlength <- igraph::mean_distance(func_path, directed=FALSE, unconnected=TRUE)

  ## BETWEENNESS CENTRALITY
  func_bw <- betweenness(fmri, weighted=T)

  ## GLOBAL EFFICIENCY
  glob_eff <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE) # Convert matrix in a graph object
  global_func_efficiency <- igraph::global_efficiency(glob_eff, directed = F)

  ## NODAL EFFICIENCY
  func_nodal_graph <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE)
  nodal_func_efficiency <- brainGraph::efficiency(func_nodal_graph, type = "nodal")
  
  ## DEGREE
  func_degree <- degree(as.matrix(fmri))
  
  ## SEGREGATION MEASURES

  ## LOCAL CLUSTERING COEFFICIENT

  ## Compute local clustering coefficient
  func_clust <- clustcoeff(as.matrix(fmri))

  ## Extract local clustering coefficient values
  func_local_clustering_coeff <- func_clust$CCi

  ## GLOBAL CLUSTERING COEFFICIENT

  ## Compute global clustering coefficient
  func_GLB_clust <- clustcoeff(as.matrix(fmri))

  ## Extract global clustering coefficient values
  func_global_clustering_coeff <- func_GLB_clust$CC

  ## LOCAL EFFICIENCY
  loc_eff <- igraph::graph_from_adjacency_matrix(as.matrix(fmri), mode = "undirected", weighted = TRUE)
  local_func_efficiency <- igraph::local_efficiency(loc_eff)

  ## SMALLWORLDNESS (error message troublshoot? decrease iterations?)
  #sw_func <- smallworldness(fmri, method="HG")
  
  
  ## CREATION DATAFRAME FOR ALL GRAPH PROPERTIES

  ## Betweenness centrality

  ## Create a dataframe for first subject results
  func_subject_betweenness <- data.frame(
    SubjectID = func_split[1,], # extract subjectID
    session = func_split[2,],  # extract session number
    func_bw = t(as.data.frame(func_bw))
  )
  colnames(func_subject_betweenness)[3:ncol(func_subject_betweenness)] <- c(paste0("func_betweenness", label))

  ## Initialize dataframe
  func_results_betweenness_thr <- rbind(func_results_betweenness_thr, func_subject_betweenness)
  rownames(func_results_betweenness_thr) <- NULL

  ## Local clustering coefficient

  ## Create a dataframe
  func_subject_clustering <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    func_local_clustering_coeff= t(as.data.frame(func_local_clustering_coeff))
  )

  ## Name of columns
  colnames(func_subject_clustering)[3:ncol(func_subject_clustering)] <- c(paste0("func_clustering_coeff", label))

  func_results_clustering_thr <- rbind(func_results_clustering_thr, func_subject_clustering)

  ## Global clustering coefficient

  # Create a dataframe
  func_global_subject_clustering <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    func_global_clustering_coeff = t(as.data.frame(func_global_clustering_coeff))
  )

  ## Append all subjects values
  func_results_global_clustering_thr <- rbind(func_results_global_clustering_thr, func_global_subject_clustering)
  rownames(func_results_global_clustering_thr) <- NULL

  ## Global efficiency

  ## Create a dataframe
  func_subject_efficiency <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],  #extract session number
    global_func_efficiency = global_func_efficiency
  )

  ## Append results
  func_results_global_efficiency_thr <- rbind(func_results_global_efficiency_thr, func_subject_efficiency)

  ## Local efficiency
  func_subject_local_efficiency <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    local_func_efficiency= t(as.data.frame(local_func_efficiency))
  )

  ## Name of columns
  colnames(func_subject_local_efficiency)[3:ncol(func_subject_local_efficiency)] <- c(paste0("func_local_efficiency", label))

  func_results_local_efficiency_thr <- rbind(func_results_local_efficiency_thr, func_subject_local_efficiency)

  ## Nodal efficiency

  ## Create a dataframe for nodal efficiency
  func_subject_nodal_efficiency <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    func_nodal_efficiency = t(as.data.frame(nodal_func_efficiency))
  )

  ## Name of columns
  colnames(func_subject_nodal_efficiency)[3:ncol(func_subject_nodal_efficiency)] <- c(paste0("nodal_func_eff_", label))
  #subject_nodal_efficiency$nodal_correlation <- nodal_corr

  ## Add results to the final output
  func_results_nodal_efficiency_thr <- rbind(func_results_nodal_efficiency_thr, func_subject_nodal_efficiency)
  rownames(func_results_nodal_efficiency_thr) <- NULL

  ## Degree
  ## Create a dataframe for degree
  func_subject_degree <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    func_degree = t(as.data.frame(func_degree))  
  )
  
  ## Name of columns
  colnames(func_subject_degree)[3:ncol(func_subject_degree)] <- c(paste0("func_degree_", label))
  
  ## Add results to the final output
  func_results_degree_thr <- rbind(func_results_degree_thr, func_subject_degree)
  rownames(func_results_degree_thr) <- NULL
  
  
  ## Smallworldness
  
  ## Create a dataframe for first subject results
  # func_sw_all_subjects <- data.frame(
  # SubjectID =func_split[1,],
  # session = func_split[2,], 
  # sw_func = sw_func$swm)
  
  ## Add results to the final output
  # func_results_smallworldness_thr <- rbind(func_results_smallworldness_thr, func_sw_all_subjects)
  # rownames(func_results_smallworldness_thr) <- NULL

  ## Pathlength

  func_pathlength_all_subjects <- data.frame(
    SubjectID = func_split[1,],
    session = func_split[2,],
    func_pathlength = func_pathlength)

  ## Initialize dataframe for all subjects
  func_results_pathlength_thr <- rbind(func_results_pathlength_thr, func_pathlength_all_subjects)
  rownames(func_results_pathlength_thr) <- NULL
}



##### Loop through each subject directory in qsirecon ##########################
file_paths <- readLines("/home/radv/ftreves/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0/connectome_list_qsirecon.txt")
file_paths <- data.frame(file_paths)

for (conn in file_paths[,1]){
  
  dwi <- read.csv(conn, header=F)
  
  print(dwi)
  
  dwi <- log(dwi) #log transformation of structural connectivity matrix
  dwi[dwi < 1] <- 0 #set negative numbers to zero
  #pheatmap(dwi, filename = paste0("dwi_pheatmap_", subject_dir, ".jpg",  cluster_rows = FALSE, cluster_cols = FALSE, show_colnames = FALSE))
  ## Rename rows and columns
  colnames(dwi) <- label
  rownames(dwi) <- label
  
  ## Vectorize the matrix 
  
  ##dwi
  #which(upper.tri(dwi))
  #dwi[which(upper.tri(dwi))]
  
  ## Check which cells in the matrix are in the upper triangle
  dwi_coordinates <- which(upper.tri(dwi, diag = FALSE), arr.ind=TRUE) 
  
  ## For loop to vectorize the dwi matrix
  dwi_columns <- c()
  dwi_vector_of_values <- c()
  
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
  dwi_vector <- cbind(session, dwi_vector)
  dwi_vector <- cbind(SubjectID,dwi_vector)
  all_dwi_vector <- rbind(all_dwi_vector, dwi_vector)
  
  
  ########################## GRAPH PROPERTIES ##########################
  
  ## INTEGRATION MEASURES

  ## PATHLENGTH
  str_path <- igraph::graph_from_data_frame(dwi)
  str_pathlength <- igraph::mean_distance(str_path, directed=FALSE, unconnected = TRUE)

  ## BETWEENNESS CENTRALITY
  str_bw <- betweenness(dwi, weighted=T)

  ## GLOBAL EFFICIENCY
  #dwi <- as.matrix(dwi)
  #dwi <- apply(dwi, 2, as.numeric)
  str_eff <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE) # Create graph from matrix dwi
  #dist_matrix <- igraph::distances(str_eff, weights = igraph::E(str_eff)$weight)
  global_str_efficiency <- igraph::global_efficiency(str_eff, directed = F)

  ## NODAL EFFICIENCY
  str_nodal_graph <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
  nodal_str_efficiency <- brainGraph::efficiency(str_nodal_graph, type = "nodal")
 
  ## DEGREE
  str_degree <- degree(as.matrix(dwi))
  
  ## SEGREGATION MEASURES

  ## LOCAL CLUSTERING COEFFICIENT
  str_clust <- clustcoeff(as.matrix(dwi)) # Compute local clustering coefficient
  str_local_clustering_coeff <- str_clust$CCi # Extract local clustering coefficient values

  ## GLOBAL CLUSTERING COEFFICIENT
  str_GLB_clust<- clustcoeff(as.matrix(dwi)) # Compute global clustering coefficient
  str_global_clustering_coeff <- str_GLB_clust$CC # Extract global clustering coefficient values

  ## LOCAL EFFICIENCY
  loc_eff <- igraph::graph_from_adjacency_matrix(as.matrix(dwi), mode = "undirected", weighted = TRUE)
  local_str_efficiency <- igraph::local_efficiency(loc_eff)

  ## SMALLWORLDNESS (error message troublshoot? decrease iterations?)
  #sw_str <- smallworldness(dwi, method="HG")

  ## CREATION DATAFRAME FOR ALL GRAPH PROPERTIES

  ## Betweenness centrality

  ## Create a dataframe for first subject results
  str_subject_betweenness <- data.frame(
    SubjectID = dwi_split[1,], # extract subjectID
    session = dwi_split[2,],  # extract session number
    str_bw = t(as.data.frame(str_bw))
  )
  colnames(str_subject_betweenness)[3:ncol(str_subject_betweenness)] <- c(paste0("str_betweenness", label))

  ## Initialize dataframe
  str_results_betweenness_log_transf <- rbind(str_results_betweenness_log_transf, str_subject_betweenness)
  rownames(str_results_betweenness_log_transf) <- NULL

  ## Local clustering coefficient

  ## Create a dataframe
  str_subject_clustering <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,], #adjust or mi arrabbio
    str_local_clustering_coeff= t(as.data.frame(str_local_clustering_coeff))
  )

  ## Name of columns
  colnames(str_subject_clustering)[3:ncol(str_subject_clustering)] <- c(paste0("str_clustering_coeff", label))

  str_results_clustering_log_transf <- rbind(str_results_clustering_log_transf, str_subject_clustering)

  ## Global clustering coefficient

  # Create a dataframe
  str_global_subject_clustering <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_global_clustering_coeff = t(as.data.frame(str_global_clustering_coeff))
  )

  ## Append all subjects values
  str_results_global_clustering_log_transf <- rbind(str_results_global_clustering_log_transf, str_global_subject_clustering)
  rownames(str_results_global_clustering_log_transf) <- NULL

  ## Global efficiency

  ## Create a dataframe
  str_subject_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],  #extract session number
    global_str_efficiency = global_str_efficiency
  )

  ## Append results
  str_results_global_efficiency_log_transf <- rbind(str_results_global_efficiency_log_transf, str_subject_efficiency)

  ## Local efficiency
  str_subject_local_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    local_str_efficiency= t(as.data.frame(local_str_efficiency))
  )

  ## Name of columns
  colnames(str_subject_local_efficiency)[3:ncol(str_subject_local_efficiency)] <- c(paste0("str_local_efficiency", label))

  str_results_local_efficiency_log_transf <- rbind(str_results_local_efficiency_log_transf, str_subject_local_efficiency)

  ## Nodal efficiency

  ## Create a dataframe for nodal efficiency
  str_subject_nodal_efficiency <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_nodal_efficiency = t(as.data.frame(nodal_str_efficiency))
  )

  ## Name of columns
  colnames(str_subject_nodal_efficiency)[3:ncol(str_subject_nodal_efficiency)] <- c(paste0("nodal_str_eff_", label))
  #subject_nodal_efficiency$nodal_correlation <- nodal_corr

  ## Add results to the final output
  str_results_nodal_efficiency_log_transf <- rbind(str_results_nodal_efficiency_log_transf, str_subject_nodal_efficiency)
  rownames(str_results_nodal_efficiency_log_transf) <- NULL

  ## Degree
  ## Create a dataframe for degree
  str_subject_degree <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_degree = t(as.data.frame(str_degree))  
  )
  
  ## Name of columns
  colnames(str_subject_degree)[3:ncol(str_subject_degree)] <- c(paste0("str_degree_", label))
  
  ## Add results to the final output
  str_results_degree_log_transf <- rbind(str_results_degree_log_transf, str_subject_degree)
  rownames(str_results_degree_log_transf) <- NULL
  
  
  ## Smallworldness
  
  ## Create a dataframe for first subject results
  # str_sw_all_subjects <- data.frame(
  # SubjectID =dwi_split[1,],
  # session = dwi_split[2,], 
  # sw_str = sw_str$swm,
  
  ## Add results to the final output
  # str_results_smallworldness_log_transf <- rbind(str_results_smallworldness_log_transf, str_sw_all_subjects)
  # rownames(str_results_smallworldness_log_transf) <- NULL

  ## Pathlength
  str_pathlength_all_subjects <- data.frame(
    SubjectID = dwi_split[1,],
    session = dwi_split[2,],
    str_pathlength = str_pathlength
  )

  ## Initialize dataframe for all subjects
  str_results_pathlength_log_transf <- rbind(str_results_pathlength_log_transf, str_pathlength_all_subjects)
  rownames(str_results_pathlength_log_transf) <- NULL

}





##### Save output #######

## GRAY MATTER MIND NETWORKS
# Combine global properties
gm_results_global_properties <- Reduce(function(x, y) merge(x, y, by=c("SubjectID", "session")),
                                       list(gm_results_global_efficiency,
                                            gm_results_global_clustering,
                                            gm_results_pathlength))

# Create output directories
output_path_global <- file.path(getwd(), "graph_properties", "MIND_networks", "global_properties")
output_path_local <- file.path(getwd(), "graph_properties", "MIND_networks", "local_properties")

dir.create(output_path_global, recursive = TRUE, showWarnings = FALSE)
dir.create(output_path_local, recursive = TRUE, showWarnings = FALSE)

# Save results
write.csv(gm_results_betweenness, file.path(output_path_local, "gm_results_betweenness.csv"), row.names = FALSE)
write.csv(gm_results_clustering, file.path(output_path_local, "gm_results_clustering.csv"), row.names = FALSE)
write.csv(gm_results_local_efficiency, file.path(output_path_local, "gm_results_local_efficiency.csv"), row.names = FALSE)
write.csv(gm_results_nodal_efficiency, file.path(output_path_local, "gm_results_nodal_efficiency.csv"), row.names = FALSE)
write.csv(gm_results_degree, file.path(output_path_local, "gm_results_degree.csv"), row.names = FALSE)
write.csv(gm_results_weighted_degree, file.path(output_path_local, "gm_results_weighted_degree.csv"), row.names = FALSE)
write.csv(gm_results_global_properties, file.path(output_path_global, "gm_results_all_global_properties.csv"), row.names = FALSE)
write.csv(gm_results_global_clustering, file.path(output_path_global, "gm_results_global_clustering.csv"), row.names = FALSE)
write.csv(gm_results_global_efficiency, file.path(output_path_global, "gm_results_global_efficiency.csv"), row.names = FALSE)
write.csv(gm_results_pathlength, file.path(output_path_global, "gm_results_pathlength.csv"), row.names = FALSE)


# ## FUNCTIONAL AND STRUCTURAL
# 
# ## Merge functional and structural global dataframes
# results_global_clustering <- merge(func_results_global_clustering_thr, str_results_global_clustering_log_transf, by = c("SubjectID", "session"))
# results_efficiency <- merge(func_results_global_efficiency_thr, str_results_global_efficiency_log_transf, by = c("SubjectID", "session"))
# #results_smallworldness <- merge(func_results_smallworldness_thr, str_results_smallworldness_log_transf, by = c("SubjectID", "session"))
# results_pathlength <- merge(func_results_pathlength_thr, str_results_pathlength_log_transf, by = c("SubjectID", "session"))
# 
# ## Functional global properties dataframe
# merged_df_func <- merge(func_results_global_efficiency_thr,func_results_global_clustering_thr, by = c("SubjectID", "session"))
# func_results_global_properties <- merge(merged_df_func, func_results_pathlength_thr, by = c("SubjectID", "session"))
# 
# ## Structural global properties dataframe
# merged_df_str <- merge(str_results_global_efficiency_log_transf, str_results_global_clustering_log_transf,  by = c("SubjectID", "session"))
# str_results_global_properties <- merge(merged_df_str, str_results_pathlength_log_transf, by = c("SubjectID", "session"))
# 
# ## Output path
# output_path_global <- "/home/radv/ftreves/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_francesca/EuroPAD/derivatives/graph_properties/global_properties/"
# output_path_local_func <- "/home/radv/ftreves/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_francesca/EuroPAD/derivatives/graph_properties/local_properties/functional_local_graph_properties/"
# output_path_local_str <- "/home/radv/ftreves/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_francesca/EuroPAD/derivatives/graph_properties/local_properties/structural_local_graph_properties/"
# 
# # ## Save as csv files
# write.csv(str_results_betweenness_log_transf, paste0(output_path_local_str, "str_results_betweenness_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_betweenness_thr, paste0(output_path_local_func, "func_results_betweenness_thr.csv"), row.names = FALSE)
# write.csv(str_results_clustering_log_transf, paste0(output_path_local_str, "str_results_clustering_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_clustering_thr, paste0(output_path_local_func, "func_results_clustering_thr.csv"), row.names = FALSE)
# write.csv(str_results_local_efficiency_log_transf, paste0(output_path_local_str, "str_results_local_efficiency_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_local_efficiency_thr, paste0(output_path_local_func, "func_results_local_efficiency_thr.csv"), row.names = FALSE)
# write.csv(str_results_nodal_efficiency_log_transf, paste0(output_path_local_str, "str_results_nodal_efficiency_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_nodal_efficiency_thr, paste0(output_path_local_func, "func_results_nodal_efficiency_thr.csv"), row.names = FALSE)
# write.csv(str_results_global_properties, paste0(output_path_global, "str_results_global_properties.csv"), row.names = FALSE)
# write.csv(func_results_global_properties, paste0(output_path_global, "func_results_global_properties.csv"), row.names = FALSE)
# write.csv(str_results_global_clustering_log_transf, paste0(output_path_global, "str_results_global_clustering_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_global_clustering_thr, paste0(output_path_global, "func_results_global_clustering_thr.csv"), row.names = FALSE)
# write.csv(str_results_global_efficiency_log_transf, paste0(output_path_global, "str_results_global_efficiency_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_global_efficiency_thr, paste0(output_path_global, "func_results_global_efficiency_thr.csv"), row.names = FALSE)
# write.csv(str_results_pathlength_log_transf, paste0(output_path_global, "str_results_pathlength_log_transf.csv"), row.names = FALSE)
# write.csv(func_results_pathlength_thr, paste0(output_path_global, "func_results_pathlength_thr.csv"), row.names = FALSE)
# write.csv(func_results_degree_thr, paste0(output_path_local_func, "func_results_degree_thr.csv"), row.names = FALSE)
# write.csv(str_results_degree_log_transf, paste0(output_path_local_str, "str_results_degree_log_transf.csv"), row.names = FALSE)
