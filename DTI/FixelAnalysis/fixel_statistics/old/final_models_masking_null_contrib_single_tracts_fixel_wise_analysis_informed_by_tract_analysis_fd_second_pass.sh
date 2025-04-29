#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-12:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

####fd#####
metric="fd"

#interaction tau*immune on IFO ILF OR#
tracts=("IFO" "ILF" "OR")
analysis_name="interaction_tau_immune_on_fd"
prsofint=("pathway1_immuneactiv_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_tau_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_tau_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done

#main effect tau on AF ATR CC IFO ILF MLF OR SLF_II# 
tracts=("AF" "ATR" "IFO" "ILF" "MLF" "OR" "SLF_II")
analysis_name="main_effect_tau_on_fd"
prsofint=("prs_apoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_tau_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_tau_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done

#interaction amyloid*prsapoe on ILF#
tracts=("ILF")
analysis_name="main_effect_amyloid_on_fd"
prsofint=("prs_apoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done

#interaction amyloid*prsnoapoe on ILF#
tracts=("ILF")
analysis_name="interaction_amyloid_prsnoapoe_on_fd"
prsofint=("prs_noapoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done

#interaction amyloid*clearance on "ILF"#
tracts=("ILF")
analysis_name="interaction_amyloid_clearance_on_fd"
prsofint=("pathway6_cleaning_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_amy_int.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done



#main effect of prsnoapoe on SLF_I SLF_II#
tracts=("SLF_I" "SLF_II")
analysis_name="main_effect_prsnoapoe_on_fd"
prsofint=("prs_noapoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}.txt ${fixeldir}/statistics_files_final_models/both_contrasts_fd_prs_apoe.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}.txt ${fixeldir}/statistics_files_final_models/both_contrasts_fd_prsnoapoe.txt ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ ${output_dir} -mask ${fixeldir}/tract_stats/final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force
		fi
	done
done




