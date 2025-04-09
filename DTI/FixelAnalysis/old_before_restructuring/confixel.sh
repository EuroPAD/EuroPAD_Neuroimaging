fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

conda activate mario

metrics=(fd log_fc fdc)

for metric in ${metrics[@]}; do
	for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do #use this for loop if you want to iterate across all tracts
			tract_name=$(basename $path_to_tract)
			echo "extracting fixels for ${metric} from ${tract_name}"
			confixel --index-file $metric/$tract_name/index.mif --directions-file $metric/$tract_name/directions.mif --cohort-file $fixeldir/template/PRS_design_matrices/${tract_name}_${metric}_cohort.csv --relative-root $fixeldir/template/tract_fixels --output-hdf5 ${tract_name}_${metric}.h5
	done
done
