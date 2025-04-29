#!/bin/bash
#SBATCH --job-name=MIND_jobs
#SBATCH --output=logs/MIND_%A_%a.out
#SBATCH --error=logs/MIND_%A_%a.err
#SBATCH --array=1-2000%50   # Run 50 jobs at a time; BATCH 2: 2001-4000%50 ; BATCH 3: 4001-5451%50 
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=0-00:30:00
#SBATCH --partition=luna-short

# Define atlas
atlas="Schaefer2018_200Parcels_7Networks_order"  # <-- replace this with your atlas variable

# Define paths
atlas_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/T1w/MIND/Schaefer2018_LocalGlobal_Parcellations_FreeSurfer5.3_fsaverage
freesurfer_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1
MIND_list=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/MIND-freesurfer-v7.1.1/MIND_list.txt

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
    if [ -f "${freesurfer_dir}/${subject}/label/lh.${atlas}.annot" ] && 
       [ -f "${freesurfer_dir}/${subject}/label/rh.${atlas}.annot" ]; then
        echo "${subject} already processed, skipping..."
        continue
    fi

    echo "Processing ${subject}..."

    # Transfer Schaefer parcellation from fsaverage to subject
    mri_surf2surf --hemi lh \
        --srcsubject fsaverage \
        --trgsubject ${subject} \
        --sval-annot ${atlas_dir}/label/lh.${atlas}.annot \
        --tval ${SUBJECTS_DIR}/${subject}/label/lh.${atlas}.annot

    mri_surf2surf --hemi rh \
        --srcsubject fsaverage \
        --trgsubject ${subject} \
        --sval-annot ${atlas_dir}/label/rh.${atlas}.annot \
        --tval ${SUBJECTS_DIR}/${subject}/label/rh.${atlas}.annot

    # Adjust pial surface files
    mv ${SUBJECTS_DIR}/${subject}/surf/lh.pial.T1 ${SUBJECTS_DIR}/${subject}/surf/lh.pial
    mv ${SUBJECTS_DIR}/${subject}/surf/rh.pial.T1 ${SUBJECTS_DIR}/${subject}/surf/rh.pial

    # Compute anatomical statistics
    mris_anatomical_stats \
        -f ${SUBJECTS_DIR}/${subject}/stats/lh.${atlas}.stats \
        -b -a ${SUBJECTS_DIR}/${subject}/label/lh.${atlas}.annot \
        ${subject} lh

    mris_anatomical_stats \
        -f ${SUBJECTS_DIR}/${subject}/stats/rh.${atlas}.stats \
        -b -a ${SUBJECTS_DIR}/${subject}/label/rh.${atlas}.annot \
        ${subject} rh

    # Restore pial file names
    mv ${SUBJECTS_DIR}/${subject}/surf/lh.pial ${SUBJECTS_DIR}/${subject}/surf/lh.pial.T1
    mv ${SUBJECTS_DIR}/${subject}/surf/rh.pial ${SUBJECTS_DIR}/${subject}/surf/rh.pial.T1

done < "${MIND_list}"
