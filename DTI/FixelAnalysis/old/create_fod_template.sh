#!/bin/bash
#SBATCH --job-name=fod_template
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50G             # max memory per node
# Request 7 hours run time
#SBATCH -t 1-10:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

mkdir -p $fixeldir/FOD_images
	
population_template $fixeldir/FOD_images -mask_dir $fixeldir/mask_images $fixeldir/template/fod_template_new.mif -nthreads 12
