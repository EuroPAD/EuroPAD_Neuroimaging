#!/bin/bash
# Script to extract the Gray-Matter White-Matter tissue contrast from FreeSurfer; largely follows the "pctsurfcon" function from FreeSurfer
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

		if [[ ! -f $sub_dir"$sub"/stats/rh.w-g.pct.$atlas.smoothed.stats ]]; then
			printf "Extracting GWC from atlas $atlas in subject $sub...\n\n"
			# left hemisphere
			mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/lh.wm.mgh --regheader $sub --cortex
			mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/lh.gm.mgh --projfrac 0.35 --regheader $sub --cortex
			mris_fwhm --i $sub_dir"$sub"/surf/lh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --s "$sub" --hemi lh
			mris_fwhm --i $sub_dir"$sub"/surf/lh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --s "$sub" --hemi lh
			mri_concat $sub_dir"$sub"/surf/lh.wm.smoothed.mgh $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --paired-diff-norm --mul 100 --o $sub_dir"$sub"/surf/lh.w-g.pct.smoothed.mgh
			mri_segstats --in $sub_dir"$sub"/surf/lh.w-g.pct.smoothed.mgh --annot $sub lh $atlas --sum $sub_dir"$sub"/stats/lh.w-g.pct.$atlas.smoothed.stats --snr

			# right hemisphere
			mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/rh.wm.mgh --regheader $sub --cortex
			mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/rh.gm.mgh --projfrac 0.35 --regheader $sub --cortex
			mris_fwhm --i $sub_dir"$sub"/surf/rh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --s "$sub" --hemi rh
			mris_fwhm --i $sub_dir"$sub"/surf/rh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --s "$sub" --hemi rh
			mri_concat $sub_dir"$sub"/surf/rh.wm.smoothed.mgh $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --paired-diff-norm --mul 100 --o $sub_dir"$sub"/surf/rh.w-g.pct.smoothed.mgh
			mri_segstats --in $sub_dir"$sub"/surf/rh.w-g.pct.smoothed.mgh --annot $sub rh $atlas --sum $sub_dir"$sub"/stats/rh.w-g.pct.$atlas.smoothed.stats --snr

		else
			printf "Skipping subject $sub, GWC already extrated...\n\n"
		fi
	done
done

printf "Script finished!\n"
