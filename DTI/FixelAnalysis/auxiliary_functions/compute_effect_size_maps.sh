fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
results_dir=${fixeldir}/template/modelarray_results/all_included_bundles_models/

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 

metrics=(fd_smooth log_fc_smooth fdc_smooth)
analyses=(prs_apoe_results_lm prs_noapoe_results_lm pathway1_immuneactiv_noapoe_BA_results_lm pathway2_signaltrasd_noapoe_BA_results_lm pathway3_inflammatory_noapoe_BA_results_lm pathway4_migration_noapoe_BA_results_lm pathway5_amyloid_noapoe_BA_results_lm pathway6_cleaning_noapoe_BA_results_lm)
predictors=('prs_apoe' 'ATA+T-' 'ATA+T+' 'sexm' 'age_tot' 'prs_apoe:ATA+T-' 'prs_apoe:ATA+T+')
predictors_AT_int=(':ATA+T-' ':ATA+T+')


for metric in ${metrics[@]}; do
	echo "generating effect sizes maps for ${metric}"
	for analysis in ${analyses[@]}; do
		if [ ${metric} == "fd_smooth" ]; then
			if [ ${analysis} == "prs_apoe_results_lm" ]; then
				cd ${results_dir}/*${metric}_${analysis}
					for predictor in ${predictors[@]}; do
						mrcalc ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -mul ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -mul 771 -add -div -sqrt ${analysis}_${predictor}.fd_smooth.abs_effect_size.mif -force

						mrcalc ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -abs -div ${analysis}_${predictor}.fd_smooth.abs_effect_size.mif -mul ${analysis}_${predictor}.fd_smooth.effect_size.mif -force
					done
			else
				cd ${results_dir}/*${metric}_${analysis}
					
					prs=${analysis//_results_lm/}
					
					mrcalc ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -mul ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -mul 770 -add -div -sqrt ${analysis}_${prs}.fd_smooth.abs_effect_size.mif -force

					mrcalc ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -abs -div ${analysis}_${prs}.fd_smooth.abs_effect_size.mif -mul ${analysis}_${prs}.fd_smooth.effect_size.mif -force

					for predictor in ${predictors_AT_int[@]}; do
						interaction="${prs}${predictor}"

						mrcalc ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -mul ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -mul 770 -add -div -sqrt ${analysis}_${interaction}.fd_smooth.abs_effect_size.mif -force

						mrcalc ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -abs -div ${analysis}_${interaction}.fd_smooth.abs_effect_size.mif -mul ${analysis}_${interaction}.fd_smooth.effect_size.mif -force
					done
			fi
		else 
			if [ ${analysis} == "prs_apoe_results_lm" ]; then
				cd ${results_dir}/*${metric}_${analysis}
					for predictor in ${predictors[@]}; do
						mrcalc ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -mul ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -mul 770 -add -div -sqrt ${analysis}_${predictor}.${metric}.abs_effect_size.mif -force

						mrcalc ${analysis}_${predictor}.statistic.mif ${analysis}_${predictor}.statistic.mif -abs -div ${analysis}_${predictor}.${metric}.abs_effect_size.mif -mul ${analysis}_${predictor}.${metric}.effect_size.mif -force
					done
			else
				cd ${results_dir}/*${metric}_${analysis}
					
					prs=${analysis//_results_lm/}
					
					mrcalc ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -mul ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -mul 769 -add -div -sqrt ${analysis}_${prs}.${metric}.abs_effect_size.mif -force

					mrcalc ${analysis}_${prs}.statistic.mif ${analysis}_${prs}.statistic.mif -abs -div ${analysis}_${prs}.${metric}.abs_effect_size.mif -mul ${analysis}_${prs}.${metric}.effect_size.mif -force

					for predictor in ${predictors_AT_int[@]}; do
						interaction="${prs}${predictor}"

						mrcalc ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -mul ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -mul 769 -add -div -sqrt ${analysis}_${interaction}.${metric}.abs_effect_size.mif -force

						mrcalc ${analysis}_${interaction}.statistic.mif ${analysis}_${interaction}.statistic.mif -abs -div ${analysis}_${interaction}.${metric}.abs_effect_size.mif -mul ${analysis}_${interaction}.${metric}.effect_size.mif -force
					done
			fi
		fi
	done
done
			
		

