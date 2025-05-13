#!/bin/bash

# Modules
module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."

# Variables
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
melodic=$studydir/derivatives/melodic-healthy-dim20-v3.15/melodic_IC.nii.gz
atlas=$studydir/code/multimodal_MRI_processing/atlases/neuroparc/Yeo-17-liberal_space-MNI152NLin6_res-2x2x2.nii.gz # adjust accordingly
atlas_name=$(basename $atlas | sed "s/.nii.gz//")
output=$studydir/derivatives/melodic-healthy-dim20-v3.15/fslcc_${atlas_name}.csv

# create output .csv
echo "melodic,$atlas_name,fslcc" > $output

# determine dimensionality of atlas
atlas_dim=$(fslinfo $atlas | grep dim4 | head -1)
atlas_dim=$(echo $atlas_dim | cut -d " " -f 2)

# if atlas is 3D, not 4D: convert each ROI to one volume in a 4D file
if [[ $atlas_dim = 1 ]]; then
    echo "atlas $atlas_name is not 4D. Converting...";
    atlas_n=$(printf '%.*f\n' 0 $(fslstats $atlas -R | cut -d " " -f 2))

    for roi in $(seq 1 $atlas_n); do
        roi_padded=$(printf "%02d" $roi);
       fslmaths $atlas -thr $roi -uthr $roi -bin roi_${roi_padded}.nii.gz;
    done
    fslmerge -t ${atlas_name}_4D.nii.gz roi_*.nii.gz;
    rm -rf roi_*.nii.gz;
    atlas=${atlas_name}_4D.nii.gz
fi

# cross correlate all MELODIC components to all atlas ROIs
fslcc -t 0 $melodic $atlas | tr -s " " | sed "s/ /,/g" | sed "s/,//" >> $output

if [[ -f ${atlas_name}_4D.nii.gz ]]; then
    rm -rf ${atlas_name}_4D.nii.gz
fi

echo "Script finished!"
