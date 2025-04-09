#!/bin/bash

module load fsl

# Paths
BIDS_dir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
scratch_dir=/home/radv/$USER/my-scratch

fmriprep_dir=$BIDS_dir/derivatives/fmriprep-v23.0.1
atlas=$BIDS_dir/code/multimodal_MRI_processing/fMRI/Extract_TimeSeries/atlas/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR.nii.gz
atlas_labels=$BIDS_dir/code/multimodal_MRI_processing/fMRI/Extract_TimeSeries/atlas/Schaefer2018_100Parcels_17Networks_order.txt

# Extract column names from the atlas labels file (second column)
column_names=$(awk '{print $2}' "$atlas_labels" | tr '\n' '\t' | sed 's/\t$//')

# Iterate over subjects in the fmriprep directory
for subject in $(ls -d ${fmriprep_dir}/sub-* | grep -v html); do
#for subject in "$fmriprep_dir"/sub-* | grep -v html | head -1226; do
    sub_id=$(basename "$subject") # Extract subject ID (e.g., sub-AMYPAD03211008)
    
    # Iterate over sessions within each subject
    for session in $(ls -d ${subject}/ses*) ; do 
    #for session in "$subject"/ses-*; do
        ses_id=$(basename "$session") # Extract session ID (e.g., ses-005)

        # Check if the 'func' directory exists
        func_dir="$session/func"
        if [ -d "$func_dir" ]; then
            # Locate the fMRI file that ends with 4smoothed.nii.gz
            fmri_file=$(find "$func_dir" -name "*4smoothed.nii.gz")
            if [ -z "$fmri_file" ]; then
                echo "No 4D fMRI file found for $sub_id $ses_id in $func_dir"
                continue
            fi

            # Define output file for the regional time series matrix
            output="${func_dir}/${sub_id}_${ses_id}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_schaefer100_yeo17_time_series.txt"
            
            # Check if output already exists
            if [ -f "$output" ]; then
                echo "Output file already exists for $sub_id $ses_id. Skipping..."
                continue
            fi

            echo "Processing $sub_id $ses_id: Extracting regional time series"

            echo "$column_names" > "$output" # Initialize empty output file

            # Extract regional time series for each region in the atlas
            for i in $(seq 1 100); do
                echo "  Processing region $i..."

                # Create binary mask for the current region
                fslmaths "$atlas" -thr $i -uthr $i -bin $scratch_dir/tail_temp_region_mask.nii.gz

                # Extract mean time series for the region
                fslmeants -i "$fmri_file" -m $scratch_dir/tail_temp_region_mask.nii.gz -o $scratch_dir/tail_temp_timeseries.txt

                # Append the time series to the output matrix
                if [ $i -eq 1 ]; then
                    # Initialize matrix with the first region
                    mv $scratch_dir/tail_temp_timeseries.txt $scratch_dir/tail_temp_matrix.txt
                else
                    # Add subsequent regions as new columns
                    paste $scratch_dir/tail_temp_matrix.txt $scratch_dir/tail_temp_timeseries.txt > $scratch_dir/tail_temp_combined.txt
                    mv $scratch_dir/tail_temp_combined.txt $scratch_dir/tail_temp_matrix.txt
                fi

                # Clean up temporary (tail) mask
                rm $scratch_dir/tail_temp_region_mask.nii.gz $scratch_dir/tail_temp_timeseries.txt
            done

            # Append the time series data matrix below the header
            cat $scratch_dir/tail_temp_matrix.txt >> "$output"
            rm $scratch_dir/tail_temp_matrix.txt

            echo "Regional time series matrix saved to $output"
        else
            echo "No func directory found for $sub_id $ses_id"
        fi
    done
done