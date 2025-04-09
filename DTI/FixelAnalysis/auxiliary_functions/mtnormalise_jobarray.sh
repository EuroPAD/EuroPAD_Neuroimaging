#!/bin/bash
#SBATCH --job-name=mt_normalise    # a convenient name for your job
#SBATCH --mem=1G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-552%40

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"

## Settings

QCdir=$1
qsiprepdir=$2
#get subject name using array variable 
subjectfolder=`head "-$SLURM_ARRAY_TASK_ID" $QCdir/subjects_sessions_to_be_processed.txt | tail -1`

session=`basename $subjectfolder`
subject=`basename $(dirname $subjectfolder)`;  # subject name


mtnormalise ${subjectfolder}/dwi/${subject}_${session}_group_average_response_wmfod.mif ${subjectfolder}/dwi/${subject}_${session}_group_average_response_wmfod_norm.mif ${subjectfolder}/dwi/${subject}_${session}_group_average_response_gmfod.mif ${subjectfolder}/dwi/${subject}_${session}_group_average_response_gmfod_norm.mif ${subjectfolder}/dwi/${subject}_${session}_group_average_response_csffod.mif ${subjectfolder}/dwi/${subject}_${session}_group_average_response_csffod_norm.mif -mask $qsiprepdir/${subject}/${session}/dwi/${subject}_${session}_mask_upsampled.mif

