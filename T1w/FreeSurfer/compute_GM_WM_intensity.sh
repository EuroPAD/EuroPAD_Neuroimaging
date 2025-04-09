#!/bin/bash
# Script to extract the Gray-Matter & White-Matter tissue intensities from FreeSurfer
# Bash Dependencies:
module load FreeSurfer/7.1.1-centos8_x86_64

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
atlasname=(aparc Schaefer2018_100Parcels_7Networks_order) # name of atlas file here

export SUBJECTS_DIR=$studydir/derivatives/freesurfer-v7.1.1 # FreeSurfer directory
sub_dir=$studydir/derivatives/freesurfer-v7.1.1/

for atlas in ${atlasname[@]}; do
	for sub in $(ls -d $SUBJECTS_DIR/sub*_ses*); do
		sub=$(basename ${sub})
		printf "\nExtracting Gray-Matter & White-Matter tissue intensities from atlas $atlas in subject $sub...\n"

		# left hemisphere
		if [[ ! -f $sub_dir"$sub"/stats/lh.gm.$atlas.smoothed.stats ]]; then

			if [[ ! -f $sub_dir"$sub"/surf/lh.wm.smoothed.mgh ]]; then
				mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/lh.wm.mgh --regheader $sub --cortex
				mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/lh.gm.mgh --projfrac 0.35 --regheader $sub --cortex
				mris_fwhm --i $sub_dir"$sub"/surf/lh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --s "$sub" --hemi lh
				mris_fwhm --i $sub_dir"$sub"/surf/lh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --s "$sub" --hemi lh
			fi
			mri_segstats --in $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --annot $sub lh $atlas --sum $sub_dir"$sub"/stats/lh.gm.$atlas.smoothed.stats --snr
			mri_segstats --in $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --annot $sub lh $atlas --sum $sub_dir"$sub"/stats/lh.wm.$atlas.smoothed.stats --snr
		else
			printf "  skipping subject $sub left hemisphere, tissue intensities already extrated...\n"
		fi
		
		# right hemisphere
		if [[ ! -f $sub_dir"$sub"/stats/rh.gm.$atlas.smoothed.stats ]]; then

			if [[ ! -f $sub_dir"$sub"/surf/rh.wm.smoothed.mgh ]]; then
				mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/rh.wm.mgh --regheader $sub --cortex
				mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/rh.gm.mgh --projfrac 0.35 --regheader $sub --cortex
				mris_fwhm --i $sub_dir"$sub"/surf/rh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --s "$sub" --hemi rh
				mris_fwhm --i $sub_dir"$sub"/surf/rh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --s "$sub" --hemi rh
			fi
			mri_segstats --in $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --annot $sub rh $atlas --sum $sub_dir"$sub"/stats/rh.gm.$atlas.smoothed.stats --snr
			mri_segstats --in $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --annot $sub rh $atlas --sum $sub_dir"$sub"/stats/rh.wm.$atlas.smoothed.stats --snr
		else
			printf "  skipping subject $sub right hemisphere, tissue intensities already extrated...\n"
		fi
	done
done

printf "Script finished!\n"
