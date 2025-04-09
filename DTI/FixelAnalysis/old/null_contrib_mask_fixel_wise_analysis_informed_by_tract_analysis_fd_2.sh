#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=40G             # max memory per node
# Request 7 hours run time
#SBATCH -t 3-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd#####
metric="fd"

#main effect tau on AF ATR CC_2 CC_3 CC_4 CC_5 CC_6 CC_7 IFO ILF MLF OR#
tract_name="main_effect_tau_on_fd"
analysis_name="main_effect_tau_on_fd"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/null_contributions* sum ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/mask_null_contributions.mif -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_stats/no_masking_results/${analysis_name}/${metric}_smooth/${prs}_int/contrasts/mask_null_contributions.mif -force
	fi
done


done
