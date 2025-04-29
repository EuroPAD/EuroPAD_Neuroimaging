#!/bin/bash
#SBATCH --job-name=compute_fdc    # a convenient name for your job
#SBATCH --mem=4G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=2      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-1510%10

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2


qsirecdir=$1
fixeldir=$2  
QCdir=$3

subjectfolder=`head "-$SLURM_ARRAY_TASK_ID" $QCdir/subjects_sessions_to_be_processed.txt | tail -1`

session=`basename $subjectfolder`
subject=`basename $(dirname $subjectfolder)`;  # subject name

# FDC
if [[ ! -d $fixeldir/template/fdc ]]; then 
mkdir $fixeldir/template/fdc
fi

if [[ ! -f $fixeldir/template/fdc/index.mif ]]; then 
cp $fixeldir/template/fc/index.mif $fixeldir/template/fdc
fi

if [[ ! -f $fixeldir/template/fdc/directions.mif ]]; then 
cp $fixeldir/template/fc/directions.mif $fixeldir/template/fdc
fi

mrcalc $fixeldir/template/fd/${subject}_${session}.mif $fixeldir/template/fc/${subject}_${session}.mif -mult $fixeldir/template/fdc/${subject}_${session}.mif

