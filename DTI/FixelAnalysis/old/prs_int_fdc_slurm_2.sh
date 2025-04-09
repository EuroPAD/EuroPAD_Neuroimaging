#!/bin/bash
#SBATCH --job-name=fixel_fdc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=40G             # max memory per node
# Request 7 hours run time
#SBATCH -t 3-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

prsofint=("pathway5_amyloid_noapoe_BA" "pathway6_cleaning_noapoe_BA")

metric="fdc"

tract_name="all_included_bundles"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fdc####
echo ${metric}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done


