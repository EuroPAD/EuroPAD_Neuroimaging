# Load required libraries
library(dplyr)

# Define file paths
mind_file <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1-Schaefer2018_100Parcels/7Networks/sub-AMYPAD03010001_ses-001_MIND-Schaefer2018_100Parcels_7Networks_order.csv"
yeo7_file <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_prithvi/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.Centroid_RAS.csv"
yeo17_file <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_prithvi/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_1mm.Centroid_RAS.csv"

# Load MIND matrix (first row contains column names)
MIND <- read.csv(mind_file, check.names = FALSE, row.names = 1)

# Load Yeo 7 and Yeo 17 labels
yeo7_labels <- read.csv(yeo7_file)
yeo17_labels <- read.csv(yeo17_file)

# Rename columns in label dataframes for clarity
colnames(yeo7_labels)[c(1,2)] <- c("ROI.Label_7", "ROI.Name_7")
colnames(yeo17_labels)[c(1,2)] <- c("ROI.Label_17", "ROI.Name_17")

# Merge Yeo7 and Yeo17 labels based on spatial coordinates (R, A, S)
yeo_both_labels <- merge(yeo7_labels, yeo17_labels, by = c("R", "A", "S"), all = TRUE)

# Create mapping between Yeo7 and Yeo17 region names
mapping <- setNames(yeo_both_labels$ROI.Name_17, yeo_both_labels$ROI.Name_7)

# Standardize MIND column names by removing prefixes (e.g., "lh_", "rh_")
colnames(MIND) <- gsub("^lh_|^rh_", "", colnames(MIND))

# Apply Yeo7 to Yeo17 name mapping for column renaming
colnames(MIND) <- mapping[colnames(MIND)]

# Order columns based on the original Yeo17 network order
ordered_columns <- yeo17_labels$ROI.Name_17
ordered_columns <- ordered_columns[ordered_columns %in% colnames(MIND)]  # Keep only valid columns
MIND <- MIND[, ordered_columns]  # Reorder columns

# Remove "lh_" and "rh_" from row names
rownames(MIND) <- gsub("^lh_|^rh_", "", rownames(MIND))
rownames(MIND) <- mapping[rownames(MIND)]
ordered_rows <- yeo17_labels$ROI.Name_17
ordered_rows <- ordered_rows[ordered_rows %in% rownames(MIND)]  # Keep only valid columns
MIND <- MIND[ordered_rows, ]  # Reorder columns

#colnames(MIND) <- NULL
#rownames(MIND) <- NULL

# Fix first row: ensure first row labels match updated column names
#MIND[1, ] <- colnames(MIND)

# Save the corrected matrix
output_file <- "/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1-Schaefer2018_100Parcels/17Networks/sub-AMYPAD03010001_ses-001_MIND-Schaefer2018_100Parcels_17Networks_order.csv"
write.csv(MIND, output_file, row.names = T)

# Print confirmation message
cat("✅ MIND network successfully mapped to Yeo17 labels and reordered! Saved to:", output_file, "\n")
