#!/bin/bash
module load Anaconda3

#conda activate leo
fmriprepdir=/home/radv/gkiziltepe/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1/participants_gulce
atlas=/home/radv/gkiziltepe/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/atlases/Schaefer400_space-MNI152NLin6_res-2x2x2.nii.gz
atlasname=schaefer400_2x2x2 # put your desired name here
scriptdir=/home/radv/gkiziltepe/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/Processing

for sub in `ls -d $fmriprepdir/sub-* | grep -v html`; do
subjname=`basename $sub`
printf "\n$subjname\n"
for ses in `ls -d $sub/ses*`; do 
sessioname=`basename $ses`
printf "  $sessioname\n"
if [[ -f $ses/func/${subjname}_${sessioname}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_${atlasname}_connectome.csv ]]; then
	printf "    Connectome already computed, skipping...\n"
else
	printf "    Computing connectome...\n"
	python $scriptdir/compute_mni_connectome.py $ses/func/${subjname}_${sessioname}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz -a $atlas -n $atlasname
fi
done 
done

printf "Script finished!\n\n"
