#Script location: /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/nawm_FA.sh

CD=${PWD}
output_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/
fa_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/FA/
subj_list=ids.txt

#subj=011EPAD00010 <- that's what one "subj" looks like

while read subj; do
	input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_1/
	if [ -d "$input_subj_dir" ];
	then
		echo "Processing Session 1..."
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
		#FLAIR in MNI is not used, so not necessary

		CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
		echo $CM
		$CM
		mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_1_wmhsegm.nii.gz

		mri_binarize --i ${output_subj_dir}${subj}_1_wmhsegm.nii.gz --min 0.2 --o ${output_subj_dir}${subj}_1_wmhsegm_bin.nii.gz #Step 3: Binarize WMH mask

		fslmaths ${output_subj_dir}${subj}_1_wmhsegm_bin.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_1_wmhsegm_bin_inverted.nii.gz #Step 4: Invert the WMH mask
		fslmaths ${fa_dir}${subj}_1_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_1_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_1_NAWM_FA.nii.gz #Step 5: Mask the FA

		echo "Processing Session 1 Finished!"

		input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_2/
		if [ -d "$input_subj_dir" ];
		then
			echo "Processing Session 2..."
			flair=${input_subj_dir}/FLAIR.nii.gz
			wmhsegm=${input_subj_dir}/WMH_SEGM.nii.gz
			
			fslorient -copysform2qform ${flair} #Step 1: Align FLAIR and WMH mask

			CM="elastix -f $fsltemplate1mm -m $flair -out ${output_subj_dir} -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
			echo $CM
			$CM

			CM="transformix -in ${flair} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
			echo $CM
			$CM
			mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_2_flair.nii.gz

			CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
			echo $CM
			$CM
			mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_2_wmhsegm.nii.gz

			mri_binarize --i ${output_subj_dir}${subj}_2_wmhsegm.nii.gz --min 0.2 --o ${output_subj_dir}${subj}_2_wmhsegm_bin.nii.gz #Step 3: Binarize WMH mask

			fslmaths ${output_subj_dir}${subj}_2_wmhsegm_bin.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_2_wmhsegm_bin_inverted.nii.gz #Step 4: Invert the WMH mask
			fslmaths ${fa_dir}${subj}_2_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_2_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_2_NAWM_FA.nii.gz #Step 5: Mask the FA

			echo "Processing Session 2 Finished!"
			
			input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_3/
			if [ -d "$input_subj_dir" ];
			then
				echo "Processing Session 3..."
				flair=${input_subj_dir}/FLAIR.nii.gz
				wmhsegm=${input_subj_dir}/WMH_SEGM.nii.gz
				
				fslorient -copysform2qform ${flair} #Step 1: Align FLAIR and WMH mask

				CM="elastix -f $fsltemplate1mm -m $flair -out ${output_subj_dir} -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
				echo $CM
				$CM

				CM="transformix -in ${flair} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
				echo $CM
				$CM
				mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_3_flair.nii.gz

				CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
				echo $CM
				$CM
				mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_3_wmhsegm.nii.gz

				mri_binarize --i ${output_subj_dir}${subj}_3_wmhsegm.nii.gz --min 0.2 --o ${output_subj_dir}${subj}_3_wmhsegm_bin.nii.gz #Step 3: Binarize WMH mask

				fslmaths ${output_subj_dir}${subj}_3_wmhsegm_bin.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_3_wmhsegm_bin_inverted.nii.gz #Step 4: Invert the WMH mask
				fslmaths ${fa_dir}${subj}_3_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_3_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_3_NAWM_FA.nii.gz #Step 5: Mask the FA

				echo "Processing Session 3 Finished!"

				input_subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/${subj}_4/
				if [ -d "$input_subj_dir" ];
				then
					echo "Processing Session 4..."
					flair=${input_subj_dir}/FLAIR.nii.gz
					wmhsegm=${input_subj_dir}/WMH_SEGM.nii.gz
					
					fslorient -copysform2qform ${flair} #Step 1: Align FLAIR and WMH mask

					CM="elastix -f $fsltemplate1mm -m $flair -out ${output_subj_dir} -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
					echo $CM
					$CM

					CM="transformix -in ${flair} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
					echo $CM
					$CM
					mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_4_flair.nii.gz

					CM="transformix -in ${wmhsegm} -out ${output_subj_dir} -tp ${output_subj_dir}/TransformParameters.2.txt"
					echo $CM
					$CM
					mv ${output_subj_dir}result.nii.gz ${output_subj_dir}${subj}_4_wmhsegm.nii.gz

					mri_binarize --i ${output_subj_dir}${subj}_4_wmhsegm.nii.gz --min 0.2 --o ${output_subj_dir}${subj}_4_wmhsegm_bin.nii.gz #Step 3: Binarize WMH mask

					fslmaths ${output_subj_dir}${subj}_4_wmhsegm_bin.nii.gz -mul -1 -add 1 ${output_subj_dir}${subj}_4_wmhsegm_bin_inverted.nii.gz #Step 4: Invert the WMH mask
					fslmaths ${fa_dir}${subj}_4_FA_FA_to_target.nii.gz -mas ${output_subj_dir}${subj}_4_wmhsegm_bin_inverted.nii.gz ${output_subj_dir}${subj}_4_NAWM_FA.nii.gz #Step 5: Mask the FA

					echo "Processing Session 4 Finished!"
				else
					echo "Session 4 does not exist; Stopping User."
				fi
			else 
				echo "Session 3 does not exist; Stopping User."
			fi

		else 
			echo "Session 2 does not exist; Stopping User."
		fi

	else
		echo "User/Session 1 does not exist; Stopping User."
	fi
done < ids.txt




