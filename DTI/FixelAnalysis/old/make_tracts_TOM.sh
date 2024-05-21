#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=30G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-03:00:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

#!/bin/bash

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
#fixeldir=/scratch/radv/mtranfa/Fixel_trial

eval "$(conda shell.bash hook)"
conda activate mario #TractSeg is needed

#module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

#create tck files using TractSeg

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files
Tracking -i ${fixeldir}/template/peaks_flip_x.nii.gz -o ${fixeldir}/template/ --tracking_format tck --nr_fibers 10000

