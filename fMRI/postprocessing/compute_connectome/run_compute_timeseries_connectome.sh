#!/bin/bash
#SBATCH --job-name=fmri_postproc
#SBATCH --output=logs/fmri_postproc_%j.out
#SBATCH --error=logs/fmri_postproc_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --partition=luna-long

module load Anaconda3

# ======== USER CONFIG ========= #
BASE_DIR="/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD"
DERIV_DIR="$BASE_DIR/derivatives/postprocessing-fmriprep-v23.0.1"
ATLAS="$BASE_DIR/code/multimodal_MRI_processing/atlases/Schaefer2018/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.nii.gz"
ATLAS_NAME="Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm"
SCRIPT_PATH="$BASE_DIR/code/multimodal_MRI_processing/fMRI/postprocessing/compute_connectome/compute_timeseries_connectome.py"
# ============================== #

for SUBJ_DIR in $(ls -d $BASE_DIR/derivatives/fmriprep-v23.0.1/sub-*/ses-*/func/ | grep -v "\.html" | head -1781); do
  BOLD_FILE=$(find "$SUBJ_DIR" -name "*task-rest_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz" | head -n 1)
  CONF_FILE=$(find "$SUBJ_DIR" -name "*desc-confounds_timeseries.tsv" | head -n 1)
  
  # Skip if key inputs are missing
  if [[ ! -f "$BOLD_FILE" || ! -f "$CONF_FILE" ]]; then
    echo "[WARN] Missing BOLD or confound file for $SUBJ_ID $SES_ID — skipping."
    continue
  fi

  SUBJ_ID=$(basename $(dirname $(dirname $SUBJ_DIR)))  
  SES_ID=$(basename $(dirname $SUBJ_DIR))              

  OUT_DIR="$DERIV_DIR/$SUBJ_ID/$SES_ID"f

  mkdir -p "$OUT_DIR"

  BASE_TAG="drop5_smooth4_bp0.01-0.1_regmotion"
  BASE_FILENAME="${SUBJ_ID}_${SES_ID}_space-MNI152NLin6Asym_desc-preproc_${BASE_TAG}_atlas-${ATLAS_NAME}"

  CONN_FILE="${OUT_DIR}/${BASE_FILENAME}_connectome.csv"

  # Skip if connectome file already exists (CHANGE ACCORDINGLY)
  if [[ -f "$CONN_FILE" ]]; then
    echo "[SKIP] Connectome already exists for ${SUBJ_ID} ${SES_ID} → $CONN_FILE"
    continue
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

done