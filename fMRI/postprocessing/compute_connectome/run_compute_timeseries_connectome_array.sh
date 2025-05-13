#!/bin/bash
#SBATCH --job-name=fmri_postproc
#SBATCH --output=logs/fmri_postproc_%A_%a.out
#SBATCH --error=logs/fmri_postproc_%A_%a.err
#SBATCH --array=1751-2751%50  # ← based on total sessions
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=0-00:15:00
#SBATCH --partition=luna-short
#SBATCH --nice=1000

module load Anaconda3

# ======== USER CONFIG ========= #
BASE_DIR="/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD"
DERIV_DIR="$BASE_DIR/derivatives/postprocessing-fmriprep-v23.0.1"
ATLAS="$BASE_DIR/code/multimodal_MRI_processing/atlases/Schaefer2018/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.nii.gz"
ATLAS_NAME="Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm"
SCRIPT_PATH="$BASE_DIR/code/multimodal_MRI_processing/fMRI/postprocessing/compute_connectome/compute_timeseries_connectome.py"
# ============================== #

# Select the indexed session folder
SUBJ_DIR=$(ls -d $BASE_DIR/derivatives/fmriprep-v23.0.1/sub-*/ses-*/func/ | grep -v "\.html" | sed -n "${SLURM_ARRAY_TASK_ID}p")

# Confirm valid input
if [[ -z "$SUBJ_DIR" ]]; then
  echo "[ERROR] No subject/session found for ID $SLURM_ARRAY_TASK_ID"
  exit 1
fi

BOLD_FILE=$(find "$SUBJ_DIR" -name "*task-rest_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz" | head -n 1)
CONF_FILE=$(find "$SUBJ_DIR" -name "*desc-confounds_timeseries.tsv" | head -n 1)

SUBJ_ID=$(basename $(dirname $(dirname "$SUBJ_DIR")))
SES_ID=$(basename $(dirname "$SUBJ_DIR"))

# Check input validity
if [[ ! -f "$BOLD_FILE" || ! -f "$CONF_FILE" ]]; then
  echo "[WARN] Missing BOLD or confound file for $SUBJ_ID $SES_ID — skipping."
  exit 0
fi

OUT_DIR="$DERIV_DIR/$SUBJ_ID/$SES_ID"
mkdir -p "$OUT_DIR"

BASE_TAG="drop5_smooth4_bp0.01-0.1_regmotion"
BASE_FILENAME="${SUBJ_ID}_${SES_ID}_space-MNI152NLin6Asym_desc-preproc_${BASE_TAG}_atlas-${ATLAS_NAME}"
CONN_FILE="${OUT_DIR}/${BASE_FILENAME}_connectome.csv"

# Skip if output exists
if [[ -f "$CONN_FILE" ]]; then
  echo "[SKIP] Connectome already exists for ${SUBJ_ID} ${SES_ID} → $CONN_FILE"
  exit 0
fi

CONFOUNDS_LIST="trans_x trans_y trans_z rot_x rot_y rot_z"

echo "[RUN] $BASE_TAG for ${SUBJ_ID}, ${SES_ID}"
python "$SCRIPT_PATH" \
  --fmri "$BOLD_FILE" \
  --atlas "$ATLAS" \
  --atlas_name "$ATLAS_NAME" \
  --output_dir "$OUT_DIR" \
  --tag "$BASE_TAG" \
  --mode both \
  --confounds "$CONF_FILE" \
  --confound_columns $CONFOUNDS_LIST \
  --smoothing 4 \
  --drop_volumes 5 \
  --detrend \
  --low_pass 0.1 \
  --high_pass 0.01 \
  --save_processed_bold