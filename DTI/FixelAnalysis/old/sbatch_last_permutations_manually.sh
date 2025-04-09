#!/bin/bash
#SBATCH --job-name=fixel_fc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:30:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

i=$1

metric="log_fc"

tract_name="all_included_bundles"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template


####prs_noapoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fc_prs_noapoe.txt ${fixeldir}/statistics_files/positive_contrast_fc_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast





