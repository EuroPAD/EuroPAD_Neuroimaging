#!/bin/bash
module load fsl

BIDS=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
DRdir=$BIDS/derivatives/dualregression-v0.6

stats_output_csv="$directory/dr_stage4_IC_voxelcount.csv"
atlasfile=$BIDS/code/multimodal_MRI_processing/atlases/yeo-17-liberal_network_4D_2mm_bin.nii.gz
n_dim=$(echo $(fslinfo $atlasfile | grep dim4 | grep -v pix) | cut -d " " -f 2) # how many dimensions/components/ROI's are there in the 4D file
n_dim_zero=$(echo $(($n_dim - 1)))
# header line
line="Filename,"
for i in $(seq -f "%02g" 0 $n_dim_zero); do
	vox=$(echo IC${i}_voxels)
	line=$(echo $line,$vox)
done

echo $line > "$stats_output_csv"

# for all files
for nii_file in `ls $directory/dr_stage2*_Z.nii.gz`; do
    filename=$(basename "$nii_file" .nii.gz)
    temp_array=("$filename,")


    for volume in $(seq 0 $n_dim_zero); do
	
        # take only $volume'th volume of file
        volume_temp=$(mktemp)
        fslroi $nii_file $volume_temp $volume 1

	    # fslmaths to mask that volume by $volume'th volume of /home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/CNF/DMN_jones.nii.gz
        mask_temp=$(mktemp)
        fslroi $mask_file $mask_temp $volume 1

        masked_file_temp=$(mktemp)
        fslmaths $volume_temp -mas $mask_temp $masked_file_temp

        # set threshhold of 3
        threshhold_file_temp=$(mktemp)
        fslmaths $masked_file_temp -thr 3 $threshhold_file_temp
	
        # get nonzero voxels of the masked volume
        stats=$(fslstats "$threshhold_file_temp" -V)
        non_zero_voxels=$(echo $stats | cut -d " " -f 1)
    
        # safe into array?
        temp_array+="$non_zero_voxels,"
    done

    #csv_row=$(IFS,; echo "$temp_array[*]")
    echo $temp_array >> "$stats_output_csv"

done
