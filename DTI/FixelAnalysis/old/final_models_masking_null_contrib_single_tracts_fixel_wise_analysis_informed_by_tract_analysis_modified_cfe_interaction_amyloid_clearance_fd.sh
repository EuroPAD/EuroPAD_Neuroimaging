#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-18:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd#####
metric="fd"

#interaction amyloid*clearance on "CC_3" "CC_4" "IFO" "ILF" "UF"#
tracts=("CC_3" "CC_4" "IFO" "ILF" "UF")
analysis_name="interaction_amyloid_clearance_on_fd"
prsofint=("pathway6_cleaning_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	echo "modified cfe parameters = -cfe_e 2 -cfe_h 6"
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/final_models_results_5_perc_ext_mask_single_bundles_amyloid_clearance_fd_modified_cfe/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}
		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 -cfe_e 2 -cfe_h 6 ${fixeldir}/statistics_files_final_models/files_prs_fd_int.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prs_apoe_amy_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		
		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 -cfe_e 2 -cfe_h 6 ${fixeldir}/statistics_files_final_models/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files_final_models/design_matrix_fd_${prs}_amy_int.txt ${fixeldir}/statistics_files_final_models/contrasts_fd_prsnoapoe_amy_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force
		fi
	done
done
