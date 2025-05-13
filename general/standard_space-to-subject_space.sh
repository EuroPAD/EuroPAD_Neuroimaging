#!/bin/bash
# script to apply transformation from MNI to subject space on an atlas
module load ANTs

stuydydir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
fmriprep=$stuydydir/derivatives/fmriprep-v23.0.1
raw=$stuydydir/rawdata
moving=$stuydydir/code/multimodal_MRI_processing/atlases/Schaefer2018/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz

for subjectname in `ls -d ${fmriprep}/sub-* | grep -v html`; do
	bidsname="`basename $subjectname`";
	printf "Applying transform(s) on atlas for subject $bidsname....\n"
	if [ `ls -d $subjectname/ses-* | wc -l` -gt 1 ]; then # fmriprep saves differently depending on whether there's one or more sessions
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`";
			fixed=$raw/$bidsname/$sesname/anat/${bidsname}_${sesname}_T1w.nii.gz
			lineartransform=$fmriprep/$bidsname/$sesname/anat/${bidsname}_${sesname}_from-orig_to-T1w_mode-image_xfm.txt
			nlineartransform=$fmriprep/$bidsname/anat/${bidsname}_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5
			output=$fmriprep/$bidsname/anat/${bidsname}_${sesname}_space-T1w_Schaefer100_1mm.nii.gz

			antsApplyTransforms -i $moving -r $fixed -o $output -n NearestNeighbor -t $nlineartransform [$lineartransform,1]
		done
	else
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`";
			fixed=$raw/$bidsname/$sesname/anat/${bidsname}_${sesname}_T1w.nii.gz
			transform=$fmriprep/$bidsname/$sesname/anat/${bidsname}_${sesname}_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5
			output=$fmriprep/$bidsname/$sesname/anat/${bidsname}_${sesname}_space-T1w_Schaefer100_1mm.nii.gz

			antsApplyTransforms -i $moving -r $fixed -o $output -n NearestNeighbor -t $transform
		done
	fi
done

printf "Script finished!\n\n"
