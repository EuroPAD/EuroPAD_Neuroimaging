#!/bin/bash
#SBATCH --job-name=dwi_yeo17    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:45:00         # time limit (DD-HH:MM)
#SBATCH --nice=100            # allow other priority jobs to go first
#SBATCH --array=1-1094%10

sleep 30s # Avoids potential race conditions in SLURM

## Use a new parcelltion to compute the connectome on the qsiprep output
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

scriptsdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing
atlas=${scriptsdir}/atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.nii.gz #Schaefer100_space-MNI152NLin6_res-1x1x1.nii.gz #schaeffer_100.nii.gz
atlasname=Schaefer_100_17Networks
LUT=${scriptsdir}/atlases/Schaefer2018_100Parcels_17Networks_order.txt # Add path to LUT
qsirecdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output

## Get subject name based on SLURM task ID
subname=$(ls -d $qsirecdir/sub-EPAD* | grep -v html | head "-$SLURM_ARRAY_TASK_ID"| tail -1)

echo $subname; 
sub=`basename $subname`; 
echo $sub 

## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 
    ses=`basename $sesfold`;
    echo $ses;

    # Define paths
    extra_connectome_dir="$qsirecdir/$sub/${ses}/dwi/extra_connectomes"
    sift2_count_csv="$extra_connectome_dir/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_sift_radius2_count_connectome.csv"
    transformed_atlas="$qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz"
    mif_atlas="$qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif"


    # **1. Skip if output file already exists**
    if [[ -f "$sift2_count_csv" ]]; then
        echo "SIFT2 count file already exists for $sub $ses. Skipping..."
        continue
    fi


    # **2. Apply transformation only if necessary**
    if [[ ! -f "$transformed_atlas" ]]; then
        echo "Applying transformation to atlas for $sub $ses..."
        antsApplyTransforms -d 3 -i "$atlas" \
            -r "$qsiprepdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz" \
            -o "$transformed_atlas" \
            -t "$qsiprepdir/$sub/${ses}/anat/${sub}_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5" \
            --float -n NearestNeighbor
    else
        echo "Atlas already transformed for $sub $ses."
    fi

    # **3. Convert to MIF only if necessary**
    if [[ ! -f "$mif_atlas" ]]; then
        echo "Converting atlas to MIF format for $sub $ses..."
        mrconvert "$transformed_atlas" "$mif_atlas"
    else
        echo "MIF atlas already exists for $sub $ses."
    fi

    # **4. Ensure extra_connectomes directory exists**
    mkdir -p "$extra_connectome_dir"

    # **5. Copy LUT file only if missing**
    if [[ -f "$LUT" && ! -f "$extra_connectome_dir/Schaefer2018_100Parcels_17Networks_order.txt" ]]; then 
        cp "$LUT" "$extra_connectome_dir/"
    fi

    # **6. Compute sift2 count connectome**
    echo "Computing SIFT2 count connectome for $sub $ses..."
    tck2connectome "$qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck" \
        "$mif_atlas" \
        "$sift2_count_csv" \
        -tck_weights_in "$qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv" \
        -out_assignments "$extra_connectome_dir/${atlasname}_atlas_assignments.txt" \
        -symmetric

    echo "Completed SIFT2 count for $sub $ses."

done
