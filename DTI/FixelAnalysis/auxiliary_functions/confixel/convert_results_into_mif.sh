fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
files_list_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/confixel_files_lists/
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

conda activate mario

metrics=(fd_smooth log_fc_smooth fdc_smooth)
analyses=(prs_apoe_results_lm prs_noapoe_results_lm pathway1_immuneactiv_noapoe_BA_results_lm pathway2_signaltrasd_noapoe_BA_results_lm pathway3_inflammatory_noapoe_BA_results_lm pathway4_migration_noapoe_BA_results_lm pathway5_amyloid_noapoe_BA_results_lm pathway6_cleaning_noapoe_BA_results_lm)
#metrics=(fdc_smooth)

#wb
#for metric in ${metrics[@]}; do
#	for analysis in ${analyses[@]}; do
#			echo "converting wb model results for ${metric}"
#			fixelstats_write --index-file $metric/index.mif --directions-file $metric/directions.mif --cohort-file $files_list_dir/wb_${metric}_cohort.csv --relative-root $fixeldir/template --#analysis-name ${analysis} --input-hdf5 wb_${metric}.h5 --output-dir wb_${metric}_${analysis}
#	done
#done

#tractwise
for metric in ${metrics[@]}; do
	for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do #use this for loop if you want to iterate across all tracts
			tract_name=$(basename $path_to_tract)
			echo "converting ${tract_name} model results for ${metric}"
			for analysis in ${analyses[@]}; do
				fixelstats_write --index-file $metric/$tract_name/index.mif --directions-file $metric/$tract_name/directions.mif --cohort-file $files_list_dir/${tract_name}_${metric}_cohort.csv --relative-root $fixeldir/template/tract_fixels --analysis-name ${analysis} --input-hdf5 ${tract_name}_${metric}.h5 --output-dir ${tract_name}_${metric}_${analysis}
			done
	done
done
