




# create folder for output
if [[ ! -d ${subname}/${ses}/dwi/cortical_scalars ]]; then 
	mkdir ${subname}/${ses}/dwi/cortical_scalars
fi



# Check if GM in T1 space already exists, otherwise run and skeletonized atlas
if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz ]]; then 

	# extract first volume of segmentation 
	fslroi ${subname}/${ses}/anat/${sub}_desc-preproc_desc-hsvs_5tt.nii.gz ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz 0 1 

	# from FS native to T1w space
	antsApplyTransforms -i ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz  -r $qsiprepdir/$sub/$ses/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz  -d 3 -o ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -n linear -t $qsiprepdir/$sub/$ses/anat/${sub}_${ses}_from-orig_to-T1w_mode-image_xfm.txt -v

	# Binarize GM mask 
	fslmaths ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -thr 0.2 -bin ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz

	#multiply atlas per gm bin 
fslmaths ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz -mas  ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz
fi





# IF IT HAS NOT BEEN DONE FOR THIS ATLAS, COMPUTE
if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt ]]; then

	touch ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt
	touch ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


	## IF LUT EXIST OTHERWISE USE FSLSTATS
	if [[ -f $LUT ]]; then 

		# iterate across column one
		for labelN in `sed 's/|/ /' $LUT | awk '{print $1}'`; do 

		#FA 
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	else ## otherwise we try with fslstats

	numboflab=`fslstats ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz -R | cut -d " " -f2`

		
		# iterate across column one
		for labelN in $(seq 1 $numboflab); do 
		#FA 
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	fi

fi
