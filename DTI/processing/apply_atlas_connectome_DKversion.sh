#!/bin/bash
#SBATCH --job-name=DKtoDWI    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1000-1658%10

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"


sleep 30s


## Use a new parcelltion to compute the connectome on the qsiprep output
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load FreeSurfer

scriptsdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing
LUT=${scriptsdir}/atlases/Schaefer2018_100Parcels_7Networks_order.txt # Add path to LUT
qsirecdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output
FSdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1




subname=$(ls -d $qsirecdir/sub* | grep -v html | head "-$SLURM_ARRAY_TASK_ID"| tail -1)

echo $subname; 
sub=`basename $subname`; 
echo $sub 
## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 


ses=`basename $sesfold`;
echo $ses;

if [[ ! -f ${subname}/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas_sift_invnodevol_radius2_count_connectome.csv ]]; then 


echo $subname; 

#### Take FS parcellation and do the label convert
fsparc=$FSdir/${sub}_${ses}/mri/aparc+aseg.mgz

if [[ ! -f $fsparc ]]; then
echo "FS parcellation not found for $sub, skipping ..."; 
continue
fi


### in FS space 
labelconvert $fsparc $FREESURFER_HOME/FreeSurferColorLUT.txt $scriptsdir/atlases/fs_default.txt ${subname}/${ses}/dwi/${sub}_${ses}_space-FS_desc-preproc_desc-DK84cortical_atlas.mif
mrconvert ${subname}/${ses}/dwi/${sub}_${ses}_space-FS_desc-preproc_desc-DK84cortical_atlas.mif ${subname}/${ses}/dwi/${sub}_${ses}_space-FS_desc-preproc_desc-DK84cortical_atlas.nii

#### We have to compute the transformation from freesurfer to T1-qsiprep space, for some reason we do not have it in the outputs 
#step 1. convert mgz to nii
brainfs=${fsparc//aparc+aseg/brain}


#step 2. compute transformation from fsnative to T1 space (qsiprep)  
antsRegistrationSyNQuick.sh -d 3 -f $qsiprepdir/$sub/$ses/anat/${sub}_desc-preproc_T1w.nii.gz -m ${subname}/${ses}/anat/fsnative_brain.nii.gz -o $qsiprepdir/$sub/$ses/anat/fsnative_to_T1wqsiprep_

#step 3. apply the transformation to the atlas ## We use preproc DWI which is in T1 space but 2 millimiters as all the outputs 
antsApplyTransforms -d 3 -i ${subname}/${ses}/dwi/${sub}_${ses}_space-FS_desc-preproc_desc-DK84cortical_atlas.nii -r $qsiprepdir/$sub/$ses/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz -t $qsiprepdir/$sub/$ses/anat/fsnative_to_T1wqsiprep_0GenericAffine.mat -o ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.nii --float -n NearestNeighbor

mrconvert ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.nii ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.mif

# remove unnecessary files
rm ${subname}/${ses}/dwi/${sub}_${ses}_space-FS_desc-preproc_desc-DK84cortical_atlas*

if [[ ! -d $qsirecdir/$sub/${ses}/dwi/extra_connectomes ]]; then 
mkdir $qsirecdir/$sub/${ses}/dwi/extra_connectomes; 
fi 

cp $scriptsdir/atlases/fs_default.txt $qsirecdir/$sub/${ses}/dwi/extra_connectomes/DK84cortical_LUT.txt # copy the schaeffer lut 

# just count
tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas_radius2_count_connectome.csv -symmetric

# sift2 count
tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas_sift_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -out_assignments $qsirecdir/$sub/${ses}/dwi/extra_connectomes/DK84cortical_atlas_assignments.txt -symmetric

# mean length
tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas_radius2_meanlength_connectome.csv -scale_length -stat_edge mean -symmetric

# sift2 count scaled inv node vol
tck2connectome $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas.mif $qsirecdir/$sub/${ses}/dwi/extra_connectomes/${sub}_${ses}_space-T1w_desc-preproc_desc-DK84cortical_atlas_sift_invnodevol_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -scale_invnodevol -symmetric


fi

done

