#!/bin/bash
#SBATCH --job-name=freesurfer    # a convenient name for your job
#SBATCH --mem=16G               # max memory per node
#SBATCH --partition=luna-long # using luna short queue
#SBATCH --cpus-per-task=4      # max CPU cores per process
#SBATCH --time=48:00:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-6%2

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"


## Settings
module load FreeSurfer

bidsraw=/home/radv/llorenzini/my-scratch/Projects/alpha-synu/rawdata
bidsoutput=/home/radv/llorenzini/my-scratch/Projects/alpha-synu/derivatives/freesurfer-v7.4.1
logfold=/home/radv/llorenzini/my-scratch/Projects/alpha-synu/freesurfer_logs
participant_index=$(($SLURM_ARRAY_TASK_ID + 1)) # position in patricipants.tsv

# create output directory if does not exist
if [[ ! -d $bidsoutput ]]; then

mkdir -p $bidsoutput; 

fi 

# get participant name
participant=`cat  $bidsraw/participants.tsv | head "-$participant_index" | tail -1` 


# manage logs
if [[ ! -d $logfold ]]; then 
mkdir $logfold; 
fi 

touch $logfold/missingT1s.txt


## Now run freesurfer if T1 in session1 exist
if [[ -f $bidsraw/sub-$participant/ses-01/anat/sub-${participant}_ses-01_T1w.nii.gz ]]; then 

singularity exec /opt/aumc-containers/singularity/freesurfer/freesurfer_bids-app-7.4.1-202309.sif python $HOME/my-scratch/Toolboxes_Data/freesurfer-master/run.py $bidsraw $bidsoutput participant --participant_label $participant --license_file /home/radv/llorenzini/license.txt --3T false --n_cpus 4 --refine_pial None --multiple_sessions longitudinal --skip_bids_validator

else 
echo  $participant >> $logfold/missingT1s.txt; 
fi

