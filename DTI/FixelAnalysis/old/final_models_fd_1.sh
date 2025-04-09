#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 6-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd#####
metric="fd"

#interaction tau*immune on CC_7 IFO ILF OR UF#
tracts=("CC_7" "IFO" "ILF" "OR" "UF")
analysis_name="interaction_tau_immune_on_fd"
prsofint=("pathway1_immuneactiv_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_tau_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_tau_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		fi
	done
done

#main effect tau on AF ATR CC_1 CC_2 CC_3 CC_4 CC_5 CC_6 CC_7 IFO ILF MLF OR SLF_I SLF_II# ++++ #interaction tau*prsapoe on CC_6 MLF OR#
tracts=("AF" "ATR" "CC_1" "CC_2" "CC_3" "CC_4" "CC_5" "CC_6" "CC_7" "IFO" "ILF" "MLF" "OR" "SLF_I" "SLF_II")
analysis_name="main_effect_tau_on_fd"
prsofint=("prs_apoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_tau_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_tau_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_tau_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		fi
	done
done


