#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:15:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

tract_name=$1
metric=$2
PRS=$3
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

##iterate across tracts and across metrics the following step##

#add for loop to do all required permutations			
fixelcfestats ${fixeldir}/template/tract_fixels/${metric}_smooth/${tract_name} ${fixeldir}/template/PRS_design_matrices/files.txt ${fixeldir}/template/PRS_design_matrices/design_matrix_${PRS}.txt ${fixeldir}/template/PRS_design_matrices/negative_contrast_PRS.txt ${fixeldir}/template/matrix/${metric}/${tract_name} ${fixeldir}/template/tract_stats/${metric}_${PRS}/${tract_name} -nshuffles 50 -force 
		

echo "Processing is done"

