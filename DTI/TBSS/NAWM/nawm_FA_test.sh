#Script location: /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/test1.sh

CD=${PWD}

fsltemplate1mm=/opt/aumc-apps/fsl/fsl-6.0.5.1/data/standard/MNI152_T1_1mm.nii.gz
output_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/
fa_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/FA/

subj=110EPAD00084

input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_1/
if [ -d "$input_subj_dir" ];
then
	flair=${input_subj_dir}/FLAIR.nii.gz
	wmhsegm=${input_subj_dir}/WMH_SEGM.nii.gz
	
	fslorient -copysform2qform ${flair} #Step 1: Align FLAIR and WMH mask

	CM="elastix -f $fsltemplate1mm -m $flair -out ${output_subj_dir} -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
	echo $CM
	$CM

	CM="transformix -in ${flair} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
	echo $CM
	$CM
	mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_1_flair.nii.gz

	CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
	echo $CM
	$CM
	mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_1_wmhsegm.nii.gz

	mri_binarize --i ${output_subj_dir}${subj}_1_wmhsegm.nii.gz --min 0.2 --o ${output_subj_dir}${subj}_1_wmhsegm_bin.nii.gz #Step 3: Binarize WMH mask
	
	fslmaths ${output_subj_dir}${subj}_1_wmhsegm_bin.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_1_wmhsegm_bin_inverted.nii.gz #Step 4: Invert the WMH mask
	fslmaths ${fa_dir}${subj}_1_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_1_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_1_NAWM_FA.nii.gz #Step 5: Mask the FA
	
else
	echo "User/Session does not exist."
fi

fslmaths /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/110EPAD00106_1_wmhsegm_bin.nii.gz -mul -1 -add 1 /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/110EPAD00106_1_wmhsegm_bin_inverted.nii.gz



#Step 4: Mask the FA with the WMH mask (in MNI)


#Step 5: Concatenate all WMH-masked FA files into one
