#!/bin/bash
#SBATCH --job-name=mask_reg    # a convenient name for your job
#SBATCH --mem=7G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-566%10

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

qsiprepdir=$1
fixeldir=$2  
qsirecdir=$3
QCdir=$4

subjectfolder=`head "-$SLURM_ARRAY_TASK_ID" $QCdir/subjects_sessions_to_be_processed.txt | tail -1`

session=`basename $subjectfolder`
subject=`basename $(dirname $subjectfolder)`;  # subject name



#### First estimate transformation
mrregister $qsirecdir/${subject}/${session}/dwi/${subject}_${session}_group_average_response_wmfod_norm.mif -mask1 /home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep/${subject}/${session}/dwi/${subject}_${session}_mask_upsampled.mif $fixeldir/template/fod_template.mif -nl_warp $fixeldir/subjects/${subject}/${session}/dwi/${subject}_${session}_to_template.mif $fixeldir/subjects/${subject}/${session}/dwi/template_to_${subject}_${session}.mif -force

## Then Apply transformation to mask
mrtransform /home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep/${subject}/${session}/dwi/${subject}_${session}_mask_upsampled.mif -warp $fixeldir/subjects/${subject}/${session}/dwi/${subject}_${session}_to_template.mif -interp nearest $fixeldir/subjects/${subject}/${session}/dwi/${subject}_${session}_space-FODtemplate_brain_mask.mif -force
