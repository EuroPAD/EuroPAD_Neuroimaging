#!/bin/bash

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
tracts_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files

results_type=final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass ####define which results you want to analyze #final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles final_models_results_5_perc_ext_mask_single_bundles final_models_results_5_perc_ext_mask_single_bundles_only_amypos final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass

results_folder=${fixeldir}/template/tract_stats/${results_type}

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2


for folder in $(ls $results_folder | grep -v results_csv); do #loop across metrics
	echo $folder
	metric=$(ls $results_folder/$folder)
	echo $metric
	predictor=$(ls $results_folder/$folder/$metric)
	echo $predictor
	for bundle in $(ls $results_folder/$folder/$metric/$predictor); do
		for result_path in $results_folder/$folder/$metric/$predictor/$bundle/contrasts/*fwe*; do #loop across tests
			result=$(basename $result_path)
			if [[ $(echo $result | grep t | grep -v permutations) ]]; then
				number=$(echo $result | grep -o '[^t]\+$' | cut -f 1 -d ".") #extract number of the test
				work_dir=$(dirname $result_path)
				
				if [[ $(echo $bundle | grep CC) ]]; then
 
					fixel2tsf ${work_dir}/fwe_1mpvalue_t${number}.mif ${tracts_folder}/to_visualize/modified_${bundle}.tck ${work_dir}/significance_t${number}.tsf -force

					fixel2tsf ${work_dir}/std_effect_t${number}.mif ${tracts_folder}/to_visualize/modified_${bundle}.tck ${work_dir}/colour_t${number}.tsf -force

					tsfsmooth -stdev 2 ${work_dir}/significance_t${number}.tsf ${work_dir}/smooth_significance_t${number}.tsf -force

				else
				
					fixel2tsf ${work_dir}/fwe_1mpvalue_t${number}.mif ${tracts_folder}/${bundle}.tck ${work_dir}/significance_t${number}.tsf -force

					fixel2tsf ${work_dir}/std_effect_t${number}.mif ${tracts_folder}/${bundle}.tck ${work_dir}/colour_t${number}.tsf -force

					tsfsmooth -stdev 2 ${work_dir}/significance_t${number}.tsf ${work_dir}/smooth_significance_t${number}.tsf -force
				fi
			fi		
		done
	done
done


