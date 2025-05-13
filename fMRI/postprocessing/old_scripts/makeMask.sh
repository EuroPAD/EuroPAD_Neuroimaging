#!/bin/bash
module load fsl

### Settings
BIDS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
fmriprepdir=$BIDS_DIR/derivatives/fmriprep-v23.0.1
#session=ses-01

## Make functional brain mask first for each subject and then for group
#1. create single subject masks
for file in `ls $fmriprepdir/sub-*/ses-0*/func/*MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask.nii.gz`; do
	filename=$(basename $file)
	printf "$filename \n"
	dir_amypad=$(dirname $file)

	if [ -f ${file//desc-smoothAROMAnonaggr_bold_mask/desc-percentage_mask} ]; then 
		printf "  subject mask already created...\n"; 
	else
		cm="fslmaths $file -Tmin -thrp 30 -bin ${file//desc-smoothAROMAnonaggr_bold_mask/desc-percentage_mask} -odt char"
		printf "  creating subject mask...\n"
		$cm
	fi
done 


#2. make list
if [ -f masklist.txt ]; then
	printf "\nmasklist.txt already exists; delete to remake...\n"; 
else
	printf "\nMaking masklist.txt...\n"
	ls $fmriprepdir/sub-*/ses-0*/func/*MNI152NLin6Asym_desc-percentage_mask* > masklist.txt
fi

#3. create group mask
printf "\nMaking group mask...\n"
fslmerge -t $fmriprepdir/concat_mask_files.nii.gz `cat masklist.txt` # 4D volume with one volume for each subject
fslmaths $fmriprepdir/concat_mask_files.nii.gz -Tmean -thr 0.75 -bin  $fmriprepdir/group_mask

#4. Smooth fMRI files within the mask 
printf "\nSmoothing fMRI files...\n"

for file in `ls $fmriprepdir/sub-*/ses-*/func/*MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask.nii.gz`; do 
	printf "$file \n"
	if [ -f ${file//.nii.gz/_4smoothed.nii.gz} ]; then 
		echo "fMRI already smoothed..."; 
	else
		cm="fslmaths $file -mas $fmriprepdir/group_mask -s 4 -mas $fmriprepdir/group_mask ${file//.nii.gz/_4smoothed.nii.gz}"; 
		$cm;
	fi
done 

printf "\nScript finished!\n"
