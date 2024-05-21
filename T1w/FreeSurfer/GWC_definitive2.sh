#!/bin/bash

module load FreeSurfer/7.1.1-centos8_x86_64
export SUBJECTS_DIR=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer # FreeSurfer directory
sub_dir=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer/
atlases=(aparc Schaefer2018_100Parcels_7Networks_order) #atlases names are in label directory (i.e., aparc, Schaefer2018_100Parcels_7Networks_order, etc...) 

for atlas in ${atlases[@]}; do
	for sub in $(ls -d $SUBJECTS_DIR/sub*_ses*); do
		sub=$(basename ${sub})
		
		printf "Extracting GWC from atlas $atlas in subject $sub...\n\n"
		mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/lh.wm.mgh --regheader $sub --cortex

		mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi lh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/lh.gm.mgh --projfrac 0.35 --regheader $sub --cortex

		mris_fwhm --i $sub_dir"$sub"/surf/lh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --s "$sub" --hemi lh

		mris_fwhm --i $sub_dir"$sub"/surf/lh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --s "$sub" --hemi lh

		mri_concat $sub_dir"$sub"/surf/lh.wm.smoothed.mgh $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --paired-diff-norm --mul 100 --o $sub_dir"$sub"/surf/lh.w-g.pct.smoothed.mgh

		mri_segstats --in $sub_dir"$sub"/surf/lh.w-g.pct.smoothed.mgh --annot $sub lh $atlas --sum $sub_dir"$sub"/stats/lh.w-g.pct.$atlas.smoothed.stats --snr

		mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --projdist -1 --o $sub_dir"$sub"/surf/rh.wm.mgh --regheader $sub --cortex

		mri_vol2surf --mov $sub_dir"$sub"/mri/rawavg.mgz --hemi rh --noreshape --interp trilinear --o $sub_dir"$sub"/surf/rh.gm.mgh --projfrac 0.35 --regheader $sub --cortex

		mris_fwhm --i $sub_dir"$sub"/surf/rh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --s "$sub" --hemi rh

		mris_fwhm --i $sub_dir"$sub"/surf/rh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --s "$sub" --hemi rh

		mri_concat $sub_dir"$sub"/surf/rh.wm.smoothed.mgh $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --paired-diff-norm --mul 100 --o $sub_dir"$sub"/surf/rh.w-g.pct.smoothed.mgh

		mri_segstats --in $sub_dir"$sub"/surf/rh.w-g.pct.smoothed.mgh --annot $sub rh $atlas --sum $sub_dir"$sub"/stats/rh.w-g.pct.$atlas.smoothed.stats --snr

	done
done

printf "Script finished!\n"
