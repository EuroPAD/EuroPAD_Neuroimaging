#!/bin/bash
#SBATCH --job-name=fod2fix_reorient    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=2      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
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


fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  $fixeldir/subjects/$subject/$session/dwi/${subject}_${session}_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif $fixeldir/subjects/$subject/$session/dwi/${subject}_${session}_space-FODtemplate_wmFixels_not_reoriented -afd fd.mif -force


fixelreorient $fixeldir/subjects/$subject/$session/dwi/${subject}_${session}_space-FODtemplate_wmFixels_not_reoriented $fixeldir/subjects/$subject/$session/dwi/${subject}_${session}_to_template.mif $fixeldir/subjects/$subject/$session/dwi/${subject}_${session}_space-FODtemplate_wmFixels
