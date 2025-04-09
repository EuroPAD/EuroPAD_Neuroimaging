#!/bin/bash

# Define paths
atlas_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/T1w/MIND/Schaefer2018_LocalGlobal_Parcellations_FreeSurfer5.3_fsaverage
freesurfer_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1
MIND_list=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1-Schaefer2018_100Parcels_7Networks/MIND_list.txt

# Load FreeSurfer module
module load FreeSurfer

# Ensure the fsaverage template is available
if [ ! -d "${freesurfer_dir}/fsaverage" ]; then
  cp -r ${FREESURFER_HOME}/subjects/fsaverage "$freesurfer_dir"
else
  echo "fsaverage folder already exists"
fi

# Set FreeSurfer subjects directory
export SUBJECTS_DIR="${freesurfer_dir}"

# Read MIND_list.txt and process only listed subjects/sessions
while IFS= read -r subject_path; do
    subject=$(basename "$subject_path")  # Extracts "sub-XXX_ses-YYY"

    # Check if Schaefer parcellation already exists
    if [ -f "${freesurfer_dir}/${subject}/label/lh.Schaefer2018_100Parcels_7Networks_order.annot" ] && 
       [ -f "${freesurfer_dir}/${subject}/label/rh.Schaefer2018_100Parcels_7Networks_order.annot" ]; then
        echo "${subject} already processed, skipping..."
        continue
    fi

    echo "Processing ${subject}..."

    # Transfer Schaefer parcellation from fsaverage to subject
    mri_surf2surf --hemi lh \
        --srcsubject fsaverage \
        --trgsubject ${subject} \
        --sval-annot ${atlas_dir}/label/lh.Schaefer2018_100Parcels_7Networks_order.annot \
        --tval ${SUBJECTS_DIR}/${subject}/label/lh.Schaefer2018_100Parcels_7Networks_order.annot

    mri_surf2surf --hemi rh \
        --srcsubject fsaverage \
        --trgsubject ${subject} \
        --sval-annot ${atlas_dir}/label/rh.Schaefer2018_100Parcels_7Networks_order.annot \
        --tval ${SUBJECTS_DIR}/${subject}/label/rh.Schaefer2018_100Parcels_7Networks_order.annot

    # Adjust pial surface files
    mv ${SUBJECTS_DIR}/${subject}/surf/lh.pial.T1 ${SUBJECTS_DIR}/${subject}/surf/lh.pial
    mv ${SUBJECTS_DIR}/${subject}/surf/rh.pial.T1 ${SUBJECTS_DIR}/${subject}/surf/rh.pial

    # Compute anatomical statistics
    mris_anatomical_stats \
        -f ${SUBJECTS_DIR}/${subject}/stats/lh.Schaefer2018_100Parcels_7Networks_order.stats \
        -b -a ${SUBJECTS_DIR}/${subject}/label/lh.Schaefer2018_100Parcels_7Networks_order.annot \
        ${subject} lh

    mris_anatomical_stats \
        -f ${SUBJECTS_DIR}/${subject}/stats/rh.Schaefer2018_100Parcels_7Networks_order.stats \
        -b -a ${SUBJECTS_DIR}/${subject}/label/rh.Schaefer2018_100Parcels_7Networks_order.annot \
        ${subject} rh

    # Restore pial file names
    mv ${SUBJECTS_DIR}/${subject}/surf/lh.pial ${SUBJECTS_DIR}/${subject}/surf/lh.pial.T1
    mv ${SUBJECTS_DIR}/${subject}/surf/rh.pial ${SUBJECTS_DIR}/${subject}/surf/rh.pial.T1

done < "${MIND_list}"
