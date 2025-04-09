#!/bin/bash
#SBATCH --job-name=fmriprep    # a convenient name for your job
#SBATCH --mem=16G               # max memory per node
#SBATCH --partition=luna-long # using luna short queue
#SBATCH --cpus-per-task=4      # max CPU cores per process
#SBATCH --time=48:00:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-6%2

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"


## modules 

bidsraw=/scratch/radv/llorenzini/Projects/alpha-synu/rawdata
bidsoutput=/scratch/radv/llorenzini/Projects/alpha-synu/derivatives/fmriprep-v23.2.3
fsdir=/scratch/radv/llorenzini/Projects/alpha-synu/derivatives/freesurfer-v7.4.1
FMRIPREP=/opt/aumc-containers/singularity/fmriprep/fmriprep-23.2.3.sif #fmriprep singularity file
participant_index=$(($SLURM_ARRAY_TASK_ID + 1)) # position in patricipants.tsv
FS_LICENSE=/home/radv/llorenzini/license.txt

# create output directory if does not exist
if [[ ! -d $bidsoutput ]]; then

mkdir -p $bidsoutput; 

fi 

# get participant name
participant=`cat  $bidsraw/participants.tsv | head "-$participant_index" | tail -1` 
subname=sub-${participant}


if [[ -d $fsdir/$subname ]]; then 

mkdir work_${participant}
singularity run --cleanenv  -B $bidsraw -B $bidsoutput $FMRIPREP $bidsraw $bidsoutput participant \
	--skip-bids-validation \
	--participant_label $participant \
	--ignore fieldmaps \
	--output-spaces MNI152NLin6Asym:res-2 MNI152NLin2009cAsym:res-2 \
	--use-syn-sdc \
	--force-syn \
	--fs-subjects-dir $fsdir \
	--fs-license-file /home/radv/llorenzini/license.txt
	-w work_${participant}


fi





