#!/bin/bash

#script to assign significa fixels to specific WM bundles based on TractSeg segmentations#
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
tracts_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_TDIs/
included_tracts=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/

results_type="final_models_results_5_perc_ext_mask_single_bundles" #define which results you want to analyze #final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles final_models_results_5_perc_ext_mask_single_bundles final_models_results_5_perc_ext_mask_single_bundles_only_amypos final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_third_pass final_models_rimask_null_contrib_results_5_perc_ext_mask_tau_immune_on_fd_third_pass_modified_cfe final_models_results_5_perc_ext_mask_single_bundles_only_amypos_modified_cfe final_models_results_5_perc_ext_mask_single_bundles_tau_immune_fd_modified_cfe final_models_results_5_perc_ext_mask_single_bundles_amyloid_clearance_fd_modified_cfe final_models_mask_null_contrib_results_5_perc_ext_mask_single_bundles_second_pass


results_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/${results_type}
csv_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/${results_type}/results_csv

mkdir $csv_dir

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

csv_file=${csv_dir}/significant_fixels_${results_type}.csv #create csv file to store values


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
				#csv_file=${work_dir}/significant_fixels_${folder}_${bundle}_${metric}_${predictor}_t${number}.csv #create csv file to store values
	
				mrthreshold $work_dir/fwe_1mpvalue_t${number}.mif -abs 0.95 $work_dir/thresholded_fixels.mif -force #threshold significant fixels
				value=$(mrstats $work_dir/fwe_1mpvalue_t${number}.mif -mask $work_dir/thresholded_fixels.mif -output count) #total number of significant fixels in results file
				echo "${bundle},${folder},${metric},${predictor},t${number},${value}" >> ${csv_file}
				#cp $csv_file $csv_dir
			fi		
		done
	done
done







