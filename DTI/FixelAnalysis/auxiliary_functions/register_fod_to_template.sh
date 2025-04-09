#!/bin/bash
#SBATCH --job-name=fod_reg    # a convenient name for your job
#SBATCH --mem=2G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:15:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-628%10

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

qsirecdir=$1
fixeldir=$2  
QCdir=$3

subjectfolder=`head "-$SLURM_ARRAY_TASK_ID" $QCdir/subjects_sessions_to_be_processed.txt | tail -1`

session=`basename $subjectfolder`
subject=`basename $(dirname $subjectfolder)`;  # subject name

mrtransform ${qsirecdir}/${subject}/$session/dwi/${subject}_${session}_group_average_response_wmfod_norm.mif -warp $fixeldir/subjects/${subject}/$session/dwi/${subject}_${session}_to_template.mif -reorient_fod no $fixeldir/subjects/${subject}/$session/dwi/${subject}_${session}_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif -force
