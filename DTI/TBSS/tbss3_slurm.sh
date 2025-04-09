#!/bin/bash
#SBATCH --job-name=tbss3    # a convenient name for your job
#SBATCH --mem=80G               # max memory per node
#SBATCH --partition=luna-long # using luna short queue
#SBATCH --cpus-per-task=12      # max CPU cores per process
#SBATCH --time=2-00:00:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first

module load fsl



module load fsl


tbssdir=/data/radv/radG/RAD/share/EUROPAD_TBSS
cd $tbssdir


tbss_3_postreg -S
