#!/bin/bash
#SBATCH --job-name=groupmask
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G              # max memory per node
#SBATCH -t 12:00:00
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000

####################################################################################
##created: 16-10-24
##updated: 16-10-24
##purpose: generate GM mask (thr 0.2) recursively for multiple subjects in a directory and then make a group mask
####################################################################################

module load fsl

## be in the fmriprep directory
user=$(whoami)
fmri_prep=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1
masks=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/fastECM/masks

## temporary file to store individual GM mask paths
gm_mask_list=$masks/gm_mask_paths.txt
concat_masks=$masks/concat_masks.nii.gz
group_gm_mask=$masks/groupmask_label-GM_probseg_MNI152NLin6Asym_0.2_thr_bin.nii.gz

> $gm_mask_list #clear the file before starting

## for loop to get into sub directory
for subject in $(ls -d $fmri_prep/sub* | grep -v html); do 
	echo $subject;
	sub=$(basename $subject);
    echo $sub

	## for loop to go over each sessions in the subject directory
	for sesfoldpath in $(ls -d ${subject}/ses*) ; do 
		echo $sesfoldpath; 
		ses=$(basename $sesfoldpath); 
		echo $ses;
			
		## Check if the anat folder exists
	    anat_dir=${subject}/${ses}/anat
	    if [[ -d $anat_dir ]]; then
	        ## Define GM mask file name	
	        gm_mask="${anat_dir}/${sub}_${ses}_label-GM_probseg_MNI152NLin6Asym_0.2_thr_bin.nii.gz"
	        gm_probseg_file="${anat_dir}/${sub}_${ses}_label-GM_probseg_MNI152NLin6Asym.nii.gz"	

		## Check if the GM probability segmentation file exists
	    if [[ -f $gm_probseg_file ]]; then
        	echo "anat folder and GM probseg file exist, processing subject: $sub, session: $ses"


	    ## conditional staments to check if the sub-directory already has a GM mask, if not, first threshold the GM and WM prob images and then add them to make the mask
		if [[ ! -e $gm_mask ]]; then
			
			echo "no GM mask, generating GM mask"

			## using fslmaths thresholding and binarizing
			fslmaths $gm_probseg_file -thr 0.2 -bin $gm_mask

			## add generated mask to the list
			echo $gm_mask
			echo "$gm_mask" >> $gm_mask_list
	    else 
		    echo "GM mask already available"
			## add available mask to the list
			echo $gm_mask			
			echo "$gm_mask" >> $gm_mask_list
	    fi	
		else
			echo "GM probseg file not found in anat folder, skipping session: $ses"
		fi
		else
			echo "No anat folder found for session: $ses, skipping"
		fi
	        cd $fmri_prep
	
	done
done

## create the group mask using fslmerge
if [[ -f $gm_mask_list ]]; then

    # Check if concat_masks and group_gm_mask already exist
    if [[ ! -f $group_gm_mask ]]; then

        # if not, then generate a group mask
        fslmerge -t $concat_masks $(cat $gm_mask_list)
		echo "Concatenated mask generated"

	    fslmaths $concat_masks -Tmean -thr 0.75 -bin $group_gm_mask
	    echo "Group mask generated"

    else
        echo "Group mask already exists, skipping generation"
    fi
    else
        echo "No Group mask generated"
fi