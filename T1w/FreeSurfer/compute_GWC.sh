#!/bin/bash

module load FreeSurfer
export SUBJECTS_DIR=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer # FreeSurfer directory
sub_dir=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer/

sub=sub-010AMYPAD00001_ses-05

	# compute white/gray contrast
	#pctsurfcon --s "$sub" --gm-proj-abs 1 --wm-proj-abs 1 --b w-g.pct.1
	pctsurfcon --s "$sub" --gm-proj-frac 0.35 --b w-g.pct --nocleanup

	# apply smoothing
	#mris_fwhm --i /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.mgh --fwhm 30 --smooth-only --o /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.smoothed.mgh --s "$sub" --hemi lh
	#mris_fwhm --i /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.mgh --fwhm 30 --smooth-only --o /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.smoothed.mgh --s "$sub" --hemi rh
	mris_fwhm --i $sub_dir"$sub"/surf/lh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --s "$sub" --hemi lh
	mris_fwhm --i $sub_dir"$sub"/surf/rh.gm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --s "$sub" --hemi rh
	mris_fwhm --i $sub_dir"$sub"/surf/lh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --s "$sub" --hemi lh
	mris_fwhm --i $sub_dir"$sub"/surf/rh.wm.mgh --fwhm 30 --smooth-only --o $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --s "$sub" --hemi rh	

	# extract stats for all parcellations
	# Desikan-Killiany
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.smoothed.mgh --annot "$sub" lh aparc --sum /usr/local/freesurfer/subjects/"$sub"/stats/lh.w-g.pct.1.aparc.smoothed.stats
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.smoothed.mgh --annot "$sub" rh aparc --sum /usr/local/freesurfer/subjects/"$sub"/stats/rh.w-g.pct.1.aparc.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --annot "$sub" lh aparc --sum $sub_dir"$sub"/stats/lh.gm.aparc.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --annot "$sub" rh aparc --sum $sub_dir"$sub"/stats/rh.gm.aparc.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --annot "$sub" lh aparc --sum $sub_dir"$sub"/stats/lh.wm.aparc.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --annot "$sub" rh aparc --sum $sub_dir"$sub"/stats/rh.wm.aparc.smoothed.stats

	# Destrieux
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.smoothed.mgh --annot "$sub" lh aparc.a2009s --sum /usr/local/freesurfer/subjects/"$sub"/stats/lh.w-g.pct.1.aparc.a2009s.smoothed.stats
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.smoothed.mgh --annot "$sub" rh aparc.a2009s --sum /usr/local/freesurfer/subjects/"$sub"/stats/rh.w-g.pct.1.aparc.a2009s.smoothed.stats

	# DKT40
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.smoothed.mgh --annot "$sub" lh aparc.DKTatlas --sum /usr/local/freesurfer/subjects/"$sub"/stats/lh.w-g.pct.1.aparc.DKTatlas.smoothed.stats
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.smoothed.mgh --annot "$sub" rh aparc.DKTatlas --sum /usr/local/freesurfer/subjects/"$sub"/stats/rh.w-g.pct.1.aparc.DKTatlas.smoothed.stats

	# Whole-brain
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/lh.w-g.pct.1.smoothed.mgh --slabel "$sub" lh /usr/local/freesurfer/subjects/"$sub"/label/lh.cortex --id 1 --sum /usr/local/freesurfer/subjects/"$sub"/stats/lh.w-g.pct.1.wb.smoothed.stats
	#mri_segstats --in /usr/local/freesurfer/subjects/"$sub"/surf/rh.w-g.pct.1.smoothed.mgh --slabel "$sub" rh /usr/local/freesurfer/subjects/"$sub"/label/rh.cortex --id 1 --sum /usr/local/freesurfer/subjects/"$sub"/stats/rh.w-g.pct.1.wb.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/lh.gm.smoothed.mgh --slabel "$sub" lh $sub_dir"$sub"/label/lh.cortex --id 1 --sum $sub_dir"$sub"/stats/lh.gm.wb.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/rh.gm.smoothed.mgh --slabel "$sub" rh $sub_dir"$sub"/label/rh.cortex --id 1 --sum $sub_dir"$sub"/stats/rh.gm.wb.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/lh.wm.smoothed.mgh --slabel "$sub" lh $sub_dir"$sub"/label/lh.cortex --id 1 --sum $sub_dir"$sub"/stats/lh.wm.wb.smoothed.stats
	mri_segstats --in $sub_dir"$sub"/surf/rh.wm.smoothed.mgh --slabel "$sub" rh $sub_dir"$sub"/label/rh.cortex --id 1 --sum $sub_dir"$sub"/stats/rh.wm.wb.smoothed.stats
