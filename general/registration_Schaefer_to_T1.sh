#!/bin/bash
# Script to bring the Schaefer atlas into subject T1-space in AMYPAD

# Modules
module load ANTs

# Cross-Subject Variables
user=lpieperhoff
studydir=/data/radv/radG/RAD/share/AMYPAD
raw=$studydir/raw/Release/rawdata
scripts=/home/radv/$user/my-rdisk/RNG/Projects/ExploreASL/AMYPAD/scripts/multimodal_MRI_processing
processing=/home/radv/lpieperhoff/my-scratch/processing/AMYPAD
output=$studydir/derivatives/ANTs/transformations # SPECIFY WHERE TO SAVE STILL: out in ANTs/transformations folder
atlas=$scripts/atlases/schaeffer_100.nii.gz
orig_WORK_DIR=$processing/logs

# USE MNI 1mm as moving

fixed=$processing/MNI152_T1_1mm_brain.nii.gz # copied manually from FSL standards folder /opt/aumc-apps/fsl/fsl-6.0.6.5/data/standard/

if [[ ! -d $orig_WORK_DIR ]]; then
	mkdir $orig_WORK_DIR
	printf "Created folder $orig_WORK_DIR...\n"
fi

if [[ ! -d $processing/raw ]]; then
	mkdir $processing/raw
	printf "Created folder $processing/raw...\n"
fi

if [[ ! -d $output ]]; then
	mkdir $output
	printf "Created folder $output...\n"
fi

# iterating over all Subjects
for sub in `ls -d $raw/sub*`; do # for all subjects "sub"
	bidsname="`basename $sub`"
	for ses in `ls -d $sub/ses*`; do # for all sessions "ses" of subject "sub"
		session="`basename $ses`"
		printf "Computing MNI to subject transform for subject $bidsname, session $session...\n"
		if [[ -d $ses/anat ]]; then #if subject "sub" has an anatomical scans folder for session "ses" 
			WORK_DIR=${orig_WORK_DIR}/$bidsname
			mkdir $WORK_DIR
			d=$processing/raw/$bidsname
			if [ ! -d $d ]; then mkdir $d; fi
			cp -rf $ses/anat/${bidsname}_${session}_T1w.nii.gz $processing/raw/$bidsname
			moving=$processing/raw/$bidsname/${bidsname}_${session}_T1w.nii.gz

			sbatch $scripts/registration_Schaefer_to_T1_slurm.sh $moving $fixed $bidsname $session $studydir $output $WORK_DIR #need to specify variables

			while [[ $(ls $orig_WORK_DIR/ | wc -l) = 1 ]]; do
				sleep 10; 
			done
			printf "   ...done!\n"
		else
			printf "...no T1w scan found for subject $bidsname, session $session... skipping!\n"
		fi
	done
done

printf "Script finished!\n"


# applying transformations
affine=${bidsname}_${session}_affine.nii.gz
#antsApplyTransforms -d 3 -i $atlas -r $fixed -o $affine -n NearestNeighbor -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat # Affine
#antsApplyTransforms -d 3 -i $affine -r $fixed -o atlasinsubject.nii.gz -n NearestNeighbor -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz # Non-linear

moving=MNI152_T1_1mm.nii.gz
fixed=sub-04000061_ses-004_T1w.nii.gz
antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIinT1_Linear.nii.gz -n Linear -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz

antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIinT1_BSpline.nii.gz -n BSpline -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz

antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIinT1_NearestNeighbor.nii.gz -n NearestNeighbor -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz


moving=MNI152_T1_1mm_brain.nii.gz
fixed=sub-04000061_ses-004_T1w.nii.gz
#antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIBraininT1_Linear.nii.gz -n Linear -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz

#antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIBraininT1_BSpline.nii.gz -n BSpline -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz

antsApplyTransforms -d 3 -i $moving -r $fixed -o MNIBraininT1_NearestNeighbor.nii.gz -n NearestNeighbor -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz


moving=Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz
fixed=sub-04000061_ses-004_T1w.nii.gz
antsApplyTransforms -d 3 -i $moving -r $fixed -o Schaefer_inT1_NearestNeighbor.nii.gz -n NearestNeighbor -t ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat -t ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz




# applying transformations
affine=${bidsname}_${session}_T1affine.nii.gz
#antsApplyTransforms -d 3 -i $fixed -r $moving -o $affine -n Linear -t [${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat,useInverse] # Affine
#antsApplyTransforms -d 3 -i $affine -r $moving -o T1inMNI.nii.gz -n Linear -t ${bidsname}_${session}_MNI-to-Subject1InverseWarp.nii.gz # Non-linear

