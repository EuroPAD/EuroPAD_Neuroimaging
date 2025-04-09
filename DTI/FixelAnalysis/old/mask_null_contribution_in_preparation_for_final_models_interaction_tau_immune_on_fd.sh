#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G             # max memory per node
# Request 7 hours run time
#SBATCH -t 1-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

eval "$(conda shell.bash hook)"

conda activate mrtrixdev #use mrtrix dev version to filter fixels based on fixel-fixel connectivity extent

export PATH=/home/radv/mtranfa/mrtrix3_dev_prova/mrtrix3/bin/:"$PATH"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

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
		output_dir=${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_third_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		
		mkdir -p ${output_dir}

		mrmath ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

		mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
		
		mkdir ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop
		
		rm -dr ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/*

		fixelcrop ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/ ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/ -force
		
		rm ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent*

		fixelconnectivity ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/ ${fixeldir}/tract_files/${tract_name}.tck ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ -extent ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent.mif -force 

		mrthreshold -percentile 5 ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent.mif ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

		mkdir -p ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name}
	
		fixelfilter ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/ smooth ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/matrix/ -mask ${fixeldir}/tract_stats/final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_second_pass/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/bundle_crop/extent_mask.mif -force

	done
done
