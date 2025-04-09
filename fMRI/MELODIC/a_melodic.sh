#!/bin/bash

#SBATCH --job-name=melodic
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G              # max memory per node
#SBATCH -t 24:00:00
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=100

# Modules
module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."

melodicversion=$(melodic -V | cut -d " " -f 3)
echo "  with MELODIC version $melodicversion..."

# Variables
BIDS=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
fmriprep=$BIDS/fmriprep-v23.0.1 
melodic=$BIDS/melodic-v${melodicversion}
keyfile=$BIDS/code/AMYPAD-PNHS_all_withEPADids_20240814.csv
scratch=/home/radv/$(whoami)/my-scratch

# Creating Derivative Directory
if [[ -d $melodic ]]; then
	echo "MELODIC directory already exists, possibly overwriting..."
fi

mkdir -p $melodic

# Input Lists for MELODIC
ls -d $fmriprep/sub-*/ses-*/func/sub*_space-MNI152NLin6Asym-brain_mask.nii.gz > $scratch/mask_list.txt # study specific, select desired input files
ls -d $fmriprep/sub-*/ses-*/func/sub*_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask_4smoothed.nii.gz > $scratch/input_list.txt # study specific, select desired input files

# Merge input files into one 4D volume
echo "Creating group mask for MELODIC, #1 concatenating mask files..."
fslmerge -t $melodic/concat_mask_files.nii.gz $(cat $scratch/mask_list.txt)
echo "Creating group mask for MELODIC, #2 thresholding mask files to obtain group mask..."
fslmaths $melodic/concat_mask_files.nii.gz -Tmean -thr 0.75 -bin  $melodic/group_mask

echo "Running MELODIC..."
melodic -i $scratch/input_list.txt -o $melodic --0all -m $melodic/group_mask -d 20 --sep_vn --nobet --report
