#!/bin/bash
#SBATCH --job-name=dwi_yeo17    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:45:00         # time limit (DD-HH:MM)
#SBATCH --nice=100            # allow other priority jobs to go first
#SBATCH --array=1-355%10

sleep 30s

## Use a new parcelltion to compute the connectome on the qsiprep output
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

scriptsdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing
atlas=${scriptsdir}/atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.nii.gz #Schaefer100_space-MNI152NLin6_res-1x1x1.nii.gz #schaeffer_100.nii.gz
atlasname=Schaefer_100_17Networks
LUT=${scriptsdir}/atlases/Schaefer2018_100Parcels_17Networks_order.txt # Add path to LUT
qsirecdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output





subname=$(ls -d $qsirecdir/sub-AMYPAD* | grep -v html | head "-$SLURM_ARRAY_TASK_ID"| tail -1)

echo $subname; 
sub=`basename $subname`; 
echo $sub 

## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 


ses=`basename $sesfold`;
echo $ses;


if [[ ! -f ${subname}/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_sift_invnodevol_radius2_count_connectome.csv ]]; then 

## Apply transformation to atlas to put it in qsiprep space 
antsApplyTransforms -d 3 -i $atlas  -r ${qsiprepdir}/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz -o $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz -t $qsiprepdir/$sub/${ses}/anat/${sub}_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5 --float -n NearestNeighbor

# Transform to MIF
mrconvert $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif



# Extract connectomes

if [[ ! -d $qsirecdir/$sub/${ses}/dwi/extra_connectomes ]]; then 
mkdir $qsirecdir/$sub/${ses}/dwi/extra_connectomes 
fi

if [[ -f $LUT ]]; then 
cp $LUT $qsirecdir/$sub/${ses}/dwi/extra_connectomes/Schaefer2018_100Parcels_17Networks_order.txt  # copy the schaeffer lut 
fi

# just count
#tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_radius2_count_connectome.csv -symmetric

# sift2 count
tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_sift_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -out_assignments $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${atlasname}_atlas_assignments.txt -symmetric

# mean length
#tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_radius2_meanlength_connectome.csv -scale_length -stat_edge mean -symmetric

# sift2 count scaled inv node vol
#tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_sift_invnodevol_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -scale_invnodevol -symmetric

else 

echo " atlas already applied for subject ${sub}"; 

fi

done

