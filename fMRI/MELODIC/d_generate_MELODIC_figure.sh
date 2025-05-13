#!/bin/bash

module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."

BIDS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
derivativesdir=$BIDS_DIR/derivatives
melodicdir=$derivativesdir/k_ns_maps/flutemetamolKsubtypes9
dim=9

mkdir -p $melodicdir/presentation

for i in `seq 1 $dim`; do # for component 1 to n
	# upscale zstat image or probmap image
	#flirt -in $melodicdir/stats/probmap_${i}.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_0.5mm -applyxfm -usesqform -out $melodicdir/presentation/probmap_${i}_highres.nii.gz; 
	flirt -in $melodicdir/stats/thresh_zstat$i.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_0.5mm -applyxfm -usesqform -out $melodicdir/presentation/thresh_zstat${i}_highres.nii.gz; 
	# overlay on high-res MNI
	overlay 1 0 $FSLDIR/data/standard/MNI152_T1_0.5mm -A $melodicdir/presentation/thresh_zstat${i}_highres.nii.gz 2.5 10 $melodicdir/presentation/${i}_overlay.nii.gz;
	# make "screenshot"
	slicer $melodicdir/presentation/${i}_overlay.nii.gz -a $melodicdir/presentation/${i}_sliced.ppm
	# convert to .png
	convert $melodicdir/presentation/${i}_sliced.ppm $melodicdir/presentation/${i}_sliced.png
done

# remove temporary files
rm -rf $melodicdir/presentation/*sliced.ppm $melodicdir/presentation/*overlay.nii.gz $melodicdir/presentation/*highres.nii.gz;

printf "Script finished!\n\n"

