#Script location: /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/nawm_MD.sh

CD=${PWD}
output_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/ #wmh masks are saved in here already, no need to put in NAWM_MD...
fa_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/FA/ #fa_dir is also the md_dir so not changing variable name from other script
subj_list=ids.txt #list of subject ID's (e.g. "011EPAD00010" to iterate over)

while read subj; do
	echo "Processing subject $subj:"
	#"ls -d" lists subjects' directories, with " | wc -l " we count the lines (1 per directory)
	n_subj_ses=$(ls -d /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_*/ | wc -l) 

	for (( n=1; n<=$n_subj_ses; n++ )); do #for sessions 1 to (number of sessions there are)
		echo "Processing session $n out of $n_subj_ses of subject $subj..."
		if [ -f ${fa_dir}${subj}_${n}_FA_to_target_MD.nii.gz ]; then
			fslmaths ${fa_dir}${subj}_${n}_FA_to_target_MD.nii.gz -mas ${output_subj_dir}${subj}_${n}_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_${n}_NAWM_MD.nii.gz
			echo "... done!"
		else 
			echo "Session $n has no processed files!"
		fi
	done
done < $subj_list

