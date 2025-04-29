#!/bin/bash
#SBATCH --job-name=GraphProps
#SBATCH --output=logs/graph_props_%j.out
#SBATCH --error=logs/graph_props_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=0-00:30:00
#SBATCH --partition=luna-short

# ======== Load environment ======== #
module load Anaconda3/2024.02-1
source activate graph_properties_env

# ======== Define paths and parameters ======== #
BASE_DIR="/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD"
PIPELINE_TYPE="fmriprep-v23.0.1"
CONNECTOME_TYPE="functional_connectome"   # or structural_connectome, MIND_connectome
ATLAS_NAME="Schaefer2018_100Parcels_17Networks"
THRESHOLD=0.2  # Only relevant for functional connectomes

ATLAS_DIR="${BASE_DIR}/code/multimodal_MRI_processing/atlases"
ATLAS_LABELS_FILE="${ATLAS_DIR}/Schaefer2018/Centroid_coordinates/${ATLAS_NAME}_order_FSLMNI152_2mm.Centroid_RAS.csv" 

INPUT_CSV_LIST="${BASE_DIR}/derivatives/${PIPELINE_TYPE}/all_${ATLAS_NAME}_${CONNECTOME_TYPE}.txt"
RESULTS_FOLDER="${BASE_DIR}/derivatives/graph_properties_bctpy-v0.6.0/graph_properties_${PIPELINE_TYPE}"

# ======== Run script ======== #
python /home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/postprocessing/compute_graph_properties/compute_graph_properties.py \
  --connectome_type "$CONNECTOME_TYPE" \
  --pipeline_type "$PIPELINE_TYPE" \
  --atlas_name "$ATLAS_NAME" \
  --base_dir "$BASE_DIR" \
  --threshold "$THRESHOLD" \
  --atlas_dir "$ATLAS_DIR" \
  --atlas_labels_file "$ATLAS_LABELS_FILE" \
  --input_csv_list "$INPUT_CSV_LIST" \
  --results_folder "$RESULTS_FOLDER"
