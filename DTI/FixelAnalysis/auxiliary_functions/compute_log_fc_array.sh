#!/bin/bash
#SBATCH --job-name=compute_log_fc    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=2      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-20%10

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2


qsirecdir=$1
fixeldir=$2  
QCdir=$3

subjectfolder=`head "-$SLURM_ARRAY_TASK_ID" $QCdir/subjects_sessions_to_be_processed.txt | tail -1`

session=`basename $subjectfolder`
subject=`basename $(dirname $subjectfolder)`;  # subject name

# Compute Fibre crossection (FC) from the warps
warp2metric $fixeldir/subjects/${subject}/${session}/dwi/${subject}_${session}_to_template.mif -fc $fixeldir/template/fixel_mask $fixeldir/template/fc ${subject}_${session}.mif

# Log FC
if [[ ! -d $fixeldir/template/log_fc ]]; then 
mkdir $fixeldir/template/log_fc
fi

if [[ ! -f $fixeldir/template/log_fc/index.mif ]]; then 
cp $fixeldir/template/fc/index.mif $fixeldir/template/log_fc
fi

if [[ ! -f $fixeldir/template/log_fc/directions.mif ]]; then 
cp $fixeldir/template/fc/directions.mif $fixeldir/template/log_fc
fi

mrcalc $fixeldir/template/fc/${subject}_${session}.mif -log $fixeldir/template/log_fc/${subject}_${session}.mif


