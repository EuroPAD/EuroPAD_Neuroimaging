#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-20:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd#####
metric="fd"

#main effect tau on CC
tracts=("CC")
analysis_name="main_effect_tau_on_fd"
prsofint=("prs_apoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_tau_int.txt ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_tau_int.txt ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done

####fc#####
metric="log_fc"

#main effect of migration pathway on CC#
tracts=("CC")
analysis_name="main_effect_migration_on_fc"
prsofint=("pathway4_migration_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fc.txt ${fixeldir}/statistics_files_final_models/design_matrix_fc_${prs}.txt ${fixeldir}/statistics_files_final_models/both_contrasts_fc_prs_apoe.txt ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force

		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fc_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fc_${prs}.txt ${fixeldir}/statistics_files_final_models/both_contrasts_fc_prsnoapoe.txt ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force

		fi
	done
done


