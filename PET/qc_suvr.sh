#!/bin/bash

module load fsl
suvrdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/suvr-v24.02.07

mkdir -p $suvrdir/qc_suvr; 

for sub in `ls -d $suvrdir/sub*`; do 
    subject=$(basename $sub)

    for ses in `ls -d $sub/ses*`; do 
        session=$(basename $ses); 
        
        if [ -f $ses/pet/sub*_space-mni_desc-smooth_space-mni_desc-suvrcereb_pet.nii.gz ]; then 
            slicer $ses/pet/sub*_space-mni_desc-smooth_space-mni_desc-suvrcereb_pet.nii.gz $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -a $suvrdir/qc_suvr/${subject}_${session}_pet_in_mni_qc.ppm; 
            echo "$ses"; 
        fi; 
    done; 
done
