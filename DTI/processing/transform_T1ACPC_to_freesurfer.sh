#!/bin/bash
#SBATCH --job-name=DWItoDK    # a convenient name for your job
#SBATCH --mem-per-cpu=6G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:45:00         # time limit (DD-HH:MM)
#SBATCH --nice=100            # allow other priority jobs to go first
#SBATCH --array=4-1645%10

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"

sleep 3s

## Use a new parcelltion to compute the connectome on the qsiprep output
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load FreeSurfer/7.1.1-centos8_x86_64

bidsdir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
scriptsdir=$bidsdir/code/multimodal_MRI_processing
qsirecdir=$bidsdir/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=$bidsdir/derivatives/qsiprep-v0.19.0 #original qsiprep output
FSdir=$bidsdir/derivatives/freesurfer-v7.1.1

subname=$(ls -d $qsirecdir/sub* | grep -v html | head "-$SLURM_ARRAY_TASK_ID" | tail -1)

echo $subname; 
sub=`basename $subname`; 
echo $sub 

## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 
    ses=`basename $sesfold`;
    echo $ses;

    if [[ ! -f $qsiprepdir/$sub/$ses/anat/T1wqsiprep_to_fsnative_0GenericAffine.mat ]]; then 
        echo $subname; 

        #### We have to compute the transformation from T1-qsiprep space to freesurfer, for some reason we do not have it in the outputs 
        #step 1. convert mgz to nii
        mrconvert $FSdir/${sub}_${ses}/mri/T1.mgz $FSdir/${sub}_${ses}/mri/T1.nii

        #step 2. compute transformation from qsiprep T1 space (T1 ACPC) to freesurfer T1 space (fsaverage)  
        antsRegistrationSyNQuick.sh -d 3 -f $FSdir/${sub}_${ses}/mri/T1.nii -m $qsiprepdir/$sub/$ses/anat/${sub}_desc-preproc_T1w.nii.gz  -o $qsiprepdir/$sub/$ses/anat/T1wqsiprep_to_fsnative_

        #step 3. remove unnecessary files
        printf "\nRemoving temporary files...\n\n"
        rm $FSdir/${sub}_${ses}/mri/T1.nii

    fi
done

echo "Script finished!"
