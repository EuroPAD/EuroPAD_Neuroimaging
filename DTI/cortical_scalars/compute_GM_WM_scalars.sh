#!/bin/bash
# Script to extract the Gray-Matter & White-Matter tissue intensities from FreeSurfer
# Bash Dependencies:
module load FreeSurfer/7.1.1-centos8_x86_64
module load ANTs

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
atlasname=(aparc Schaefer2018_100Parcels_7Networks_order) # name of atlas file here
scalars=(fa md) # name of DTI scalars

export SUBJECTS_DIR=$studydir/derivatives/freesurfer-v7.1.1 # FreeSurfer directory
sub_dir=$studydir/derivatives/freesurfer-v7.1.1/
qsiprep_dir=$studydir/derivatives/qsiprep-v0.19.0
qsirecon_dir=$studydir/derivatives/qsirecon-v0.19.0


for sub in $(ls -d $qsirecon_dir/sub-* | head -1); do
	subject=$(basename $sub);

	for ses in $(ls -d $sub/ses-*); do
		session=$(basename $ses);

		md=${sub_dir}${subject}_${session}/mri/md.mgz
		fa=${sub_dir}${subject}_${session}/mri/fa.mgz
		rm -rf $md $fa ${sub_dir}${subject}_${session}/mri/*.nii.gz

		# transform MD&FA maps to fsnative, then convert .nii.gz->.mgz
		if [[ ! -f $fa ]]; then

			if [[ -d ${sub_dir}${subject}_${session} ]]; then
				# for MD
				# 1=luigi's affine only; 2=luigi's affine+warp; 3=qsiprep affine only; 4=qsiprep affine+warp;
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md.nii.gz -n Linear -t [$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_0GenericAffine.mat,1] #$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_luigi_warp_bspline.nii.gz -n BSpline -t $qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz [$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_0GenericAffine.mat,1]
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_qsiprep_affine.nii.gz -n Linear -t [${qsiprep_dir}/${subject}/${session}/anat/${subject}_${session}_from-orig_to-T1w_mode-image_xfm.txt,1]
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_qsiprep_warp.nii.gz -n Linear -t ${qsiprep_dir}/${subject}/${session}/anat/${subject}_${session}_from-orig_to-T1w_mode-image_xfm.txt $qsiprep_dir/$subject/$session/anat/${subject}_from-T1wACPC_to-T1wNative_mode-image_xfm.mat
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_qsiprep_warponly.nii.gz -n Linear -t $qsiprep_dir/$subject/$session/anat/${subject}_from-T1wACPC_to-T1wNative_mode-image_xfm.mat
				#my own:
				antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_leo_affine.nii.gz -n Linear -t $qsiprep_dir/$subject/$session/anat/T1wqsiprep_to_fsnative_0GenericAffine.mat #$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz
				antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/md_leo_warp.nii.gz -n Linear -t $qsiprep_dir/$subject/$session/anat/T1wqsiprep_to_fsnative_0GenericAffine.mat $qsiprep_dir/$subject/$session/anat/T1wqsiprep_to_fsnative_1Warp.nii.gz

				#mri_convert ${sub_dir}${subject}_${session}/mri/md.nii.gz $md
				#rm -rf ${sub_dir}${subject}_${session}/mri/md.nii.gz

				# for FA
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa.nii.gz -n Linear -t [${qsiprep_dir}/${subject}/${session}/anat/fsnative_to_T1wqsiprep_0GenericAffine.mat,1] #$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_luigi_warp_bspline.nii.gz -n BSpline -t $qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz [${qsiprep_dir}/${subject}/${session}/anat/fsnative_to_T1wqsiprep_0GenericAffine.mat,1]
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_qsiprep_affine.nii.gz -n Linear -t [${qsiprep_dir}/${subject}/${session}/anat/${subject}_${session}_from-orig_to-T1w_mode-image_xfm.txt,1]
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_qsiprep_warp.nii.gz -n Linear -t ${qsiprep_dir}/${subject}/${session}/anat/${subject}_${session}_from-orig_to-T1w_mode-image_xfm.txt $qsiprep_dir/$subject/$session/anat/${subject}_from-T1wACPC_to-T1wNative_mode-image_xfm.mat
				#antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_qsiprep_warponly.nii.gz -n Linear -t $qsiprep_dir/$subject/$session/anat/${subject}_from-T1wACPC_to-T1wNative_mode-image_xfm.mat
				#my own:
				antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_leo_affine.nii.gz -n Linear -t ${qsiprep_dir}/${subject}/${session}/anat/T1wqsiprep_to_fsnative_0GenericAffine.mat #$qsiprep_dir/$subject/$session/anat/fsnative_to_T1wqsiprep_1InverseWarp.nii.gz
				antsApplyTransforms -i $qsirecon_dir/$subject/$session/dwi/*_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -r $qsirecon_dir/$subject/$session/anat/fsnative_brain.nii.gz -d 3 -o ${sub_dir}${subject}_${session}/mri/fa_leo_warp.nii.gz -n Linear -t ${qsiprep_dir}/${subject}/${session}/anat/T1wqsiprep_to_fsnative_0GenericAffine.mat $qsiprep_dir/$subject/$session/anat/T1wqsiprep_to_fsnative_1Warp.nii.gz

				#mri_convert ${sub_dir}${subject}_${session}/mri/fa.nii.gz $fa
				#rm -rf ${sub_dir}${subject}_${session}/mri/fa.nii.gz

			else
				echo "Scalars exist but no FreeSurfer found for ${subject}_${session}"
			fi
		fi
	break # testing
		# now make surface files, compute for WM & GM along tissue boundary, smooth, segment
		for atlas in ${atlasname[@]}; do
			for phenotype in ${scalars[@]}; do
			printf "\nExtracting Gray-Matter & White-Matter $phenotype from atlas $atlas in $subject, $session...\n"

				# left hemisphere
				if [[ ! -f $sub_dir${subject}_${session}/stats/lh.gm.$phenotype.$atlas.smoothed.stats ]]; then

					if [[ ! -f $sub_dir${subject}_${session}/surf/lh.wm.$phenotype.smoothed.mgh ]]; then
						mri_vol2surf --mov $sub_dir${subject}_${session}/mri/$phenotype.mgz --hemi lh --noreshape --interp trilinear --projdist -1 --o $sub_dir${subject}_${session}/surf/lh.wm.$phenotype.mgh --regheader ${subject}_${session} --cortex
						mri_vol2surf --mov $sub_dir${subject}_${session}/mri/$phenotype.mgz --hemi lh --noreshape --interp trilinear --o $sub_dir${subject}_${session}/surf/lh.gm.$phenotype.mgh --projfrac 0.35 --regheader ${subject}_${session} --cortex
						mris_fwhm --i $sub_dir${subject}_${session}/surf/lh.gm.$phenotype.mgh --fwhm 30 --smooth-only --o $sub_dir${subject}_${session}/surf/lh.gm.$phenotype.smoothed.mgh --s ${subject}_${session} --hemi lh
						mris_fwhm --i $sub_dir${subject}_${session}/surf/lh.wm.$phenotype.mgh --fwhm 30 --smooth-only --o $sub_dir${subject}_${session}/surf/lh.wm.$phenotype.smoothed.mgh --s ${subject}_${session} --hemi lh
					fi
					mri_segstats --in $sub_dir${subject}_${session}/surf/lh.gm.$phenotype.smoothed.mgh --annot ${subject}_${session} lh $atlas --sum $sub_dir${subject}_${session}/stats/lh.gm.$phenotype.$atlas.smoothed.stats --snr
					mri_segstats --in $sub_dir${subject}_${session}/surf/lh.wm.$phenotype.smoothed.mgh --annot ${subject}_${session} lh $atlas --sum $sub_dir${subject}_${session}/stats/lh.wm.$phenotype.$atlas.smoothed.stats --snr
				else
					printf "  skipping subject ${subject}_${session} left hemisphere, DTI scalars already extrated...\n"
				fi
		
				# right hemisphere
				if [[ ! -f $sub_dir${subject}_${session}/stats/rh.gm.$phenotype.$atlas.smoothed.stats ]]; then

					if [[ ! -f $sub_dir${subject}_${session}/surf/rh.wm.$phenotype.smoothed.mgh ]]; then
						mri_vol2surf --mov $sub_dir${subject}_${session}/mri/$phenotype.mgz --hemi rh --noreshape --interp trilinear --projdist -1 --o $sub_dir${subject}_${session}/surf/rh.wm.$phenotype.mgh --regheader ${subject}_${session} --cortex
						mri_vol2surf --mov $sub_dir${subject}_${session}/mri/$phenotype.mgz --hemi rh --noreshape --interp trilinear --o $sub_dir${subject}_${session}/surf/rh.gm.$phenotype.mgh --projfrac 0.35 --regheader ${subject}_${session} --cortex
						mris_fwhm --i $sub_dir${subject}_${session}/surf/rh.gm.$phenotype.mgh --fwhm 30 --smooth-only --o $sub_dir${subject}_${session}/surf/rh.gm.$phenotype.smoothed.mgh --s ${subject}_${session} --hemi rh
						mris_fwhm --i $sub_dir${subject}_${session}/surf/rh.wm.$phenotype.mgh --fwhm 30 --smooth-only --o $sub_dir${subject}_${session}/surf/rh.wm.$phenotype.smoothed.mgh --s ${subject}_${session} --hemi rh
					fi
					mri_segstats --in $sub_dir${subject}_${session}/surf/rh.gm.$phenotype.smoothed.mgh --annot ${subject}_${session} rh $atlas --sum $sub_dir${subject}_${session}/stats/rh.gm.$phenotype.$atlas.smoothed.stats --snr
					mri_segstats --in $sub_dir${subject}_${session}/surf/rh.wm.$phenotype.smoothed.mgh --annot ${subject}_${session} rh $atlas --sum $sub_dir${subject}_${session}/stats/rh.wm.$phenotype.$atlas.smoothed.stats --snr
				else
					printf "  skipping subject ${subject}_${session} right hemisphere, DTI scalars already extrated...\n"
				fi
			done
		done
	done
done

printf "Script finished!\n"
