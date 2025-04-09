#!/bin/bash

# ======== USER CONFIG ========= #
BASE_DIR="/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/Brain_Network"
ATLAS="$BASE_DIR/Extract_TimeSeries/atlas/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR.nii.gz"
ATLAS_NAME="Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR"
SCRIPT_PATH="$BASE_DIR/Construct_Connectome/compute_timeseries_connectome.py"
# ============================== #

for SUBJ_DIR in $BASE_DIR/example_subjects/sub-*/ses-*/func/; do
  BOLD_FILE=$(ls ${SUBJ_DIR}/*task-rest_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz)
  CONF_FILE=$(ls ${SUBJ_DIR}/*desc-confounds_timeseries.tsv)
  SUBJ_ID=$(basename $(dirname $(dirname $SUBJ_DIR)))

  if [[ -f "${SUBJ_DIR}/${SUBJ_ID}_space-MNI152NLin6Asym_desc-preproc_drop5_smooth4_bp0.01-0.1_regall_atlas-${ATLAS_NAME}_timeseries.csv" && -f "${SUBJ_DIR}/${SUBJ_ID}_space-MNI152NLin6Asym_desc-preproc_drop5_smooth4_bp0.01-0.1_regall_atlas-${ATLAS_NAME}_connectome.csv" ]]; then
    echo "[SKIP] drop5_smooth4_bp0.01-0.1_regmotion already exists for ${SUBJ_ID}"
    continue
  fi

  echo "[RUN] drop5_smooth4_bp0.01-0.1_regmotion for ${SUBJ_ID}"
  python "$SCRIPT_PATH" \
    --fmri "$BOLD_FILE" \
    --atlas "$ATLAS" \
    --atlas_name "$ATLAS_NAME" \
    --output_dir "$SUBJ_DIR" \
    --tag "drop5_smooth4_bp0.01-0.1_regmotion" \
    --mode both \
    --confounds "$CONF_FILE" \
    --confound_columns trans_x trans_y trans_z rot_x rot_y rot_z \
    --smoothing 4 \
    --drop_volumes 5 \
    --detrend \
    --low_pass 0.1 \
    --high_pass 0.01 \

done
