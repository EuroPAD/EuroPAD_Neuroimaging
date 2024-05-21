#Script location: /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/nawm_FA_MD.sh

#Necessary single steps:
#Step 1: Check if FLAIR transformation exists, if yes skip to step #4, if no then compute FLAIR transformation
#Step 2: Transform FLAIR to MNI space
#Step 3: Transform WMH segmentation to MNI space
#Step 4: Binarize WMH mask (currently threshold 0.5)
#Step 5: Invert binarized WMH mask
#Step 6: Apply WMH mask on FA file and on MD file

#Script improvement: ask for threshold value and use answer as input for mri_binarize

CD=${PWD}
output_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/ #wmh masks are saved in here already, no need to put in NAWM_MD...
fa_md_dir_1=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/FA/ 
fa_md_dir_long=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/longitudinal_tbss/FA/ 
subj_list=ids.txt #list of subject ID's (e.g. "011EPAD00010" to iterate over)

while read subj; do
	echo "Processing subject $subj:"
	#"ls -d" lists subjects' directories, with " | wc -l " we count the lines (1 per directory)
	n_subj_ses=$(ls -d /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_*/ | wc -l) 

	for n in $(seq 1 $n_subj_ses); do                 
		input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_${n}/
		flair=${input_subj_dir}/FLAIR.nii.gz
		wmhsegm=${input_subj_dir}/WMH_SEGM.nii.gz
		echo "Processing session $n out of $n_subj_ses of subject $subj..."

		if [ -f ${fa_md_dir_long}${subj}_${n}_FA_FA_to_target.nii.gz ] || [ -f ${fa_md_dir_1}${subj}_${n}_FA_FA_to_target.nii.gz ]; then #if this subject has DTI scalars (just checking FA):
			if [ $n == 1 ]; then
				fa_md_dir=$fa_md_dir_1 #session 1 is stored in this directory
			else 
				fa_md_dir=$fa_md_dir_long #all other sessions are stored here
			fi

			if [ -f ${output_subj_dir}${subj}_${n}_flair.nii.gz ]; then #_flair.nii.gz is the MNI transformed FLAIR 
				echo "FLAIR in MNI space already exists for session $n of user $subj!" #we only need to apply the wmh mask to the FA now
				echo "Binarizing WMH mask with minimum threshold 0.5..."
				mri_binarize --i ${output_subj_dir}${subj}_${n}_wmhsegm.nii.gz --min 0.5 --o ${output_subj_dir}${subj}_${n}_wmhsegm_bin050.nii.gz #Step 3: Binarize WMH mask
				echo "Inverting WMH mask..."
				fslmaths ${output_subj_dir}${subj}_${n}_wmhsegm_bin050.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz #Step 4: Invert the WMH mask
				echo "Applying WMH mask to FA..."
				fslmaths ${fa_md_dir}${subj}_${n}_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz ${output_subj_dir}${subj}_${n}_nawm_050_FA.nii.gz
				echo "Applying WMH mask to MD..."
				fslmaths ${fa_md_dir}${subj}_${n}_FA_to_target_MD.nii.gz -mas ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz ${output_subj_dir}${subj}_${n}_nawm_050_MD.nii.gz
			else
				fslorient -copysform2qform ${flair} #Align FLAIR and WMH mask

				echo "Computing FLAIR transform to MNI space..."
				CM="elastix -f $fsltemplate1mm -m $flair -out ${output_subj_dir} -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
				echo $CM
				$CM

				CM="transformix -in ${flair} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
				echo $CM
				$CM
				mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_${n}_flair.nii.gz
				#FLAIR in MNI is not used, so not necessary

				CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
				echo $CM
				$CM
				mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_${n}_wmhsegm.nii.gz

				echo "Binarizing WMH mask with minimum threshold 0.5..."
				mri_binarize --i ${output_subj_dir}${subj}_${n}_wmhsegm.nii.gz --min 0.5 --o ${output_subj_dir}${subj}_${n}_wmhsegm_bin050.nii.gz #Step 3: Binarize WMH mask
				echo "Inverting WMH mask..."
				fslmaths ${output_subj_dir}${subj}_${n}_wmhsegm_bin050.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz #Step 4: Invert the WMH mask
				echo "Applying WMH mask to FA..."
				fslmaths ${fa_md_dir}${subj}_${n}_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz ${output_subj_dir}${subj}_${n}_nawm_050_FA.nii.gz
				echo "Applying WMH mask to MD..."
				fslmaths ${fa_md_dir}${subj}_${n}_FA_to_target_MD.nii.gz -mas ${output_subj_dir}${subj}_${n}_wmhsegm_bin050_inverted.nii.gz ${output_subj_dir}${subj}_${n}_nawm_050_MD.nii.gz
			fi
		echo "... done with processing session $n out of $n_subj_ses of subject $subj!"
		else 
			echo "Session $n has no processed files!"
		fi
	done
done < $subj_list


#(( n=1; n<=$n_subj_ses; n++ )); do for sessions 1 to (number of sessions there are)
