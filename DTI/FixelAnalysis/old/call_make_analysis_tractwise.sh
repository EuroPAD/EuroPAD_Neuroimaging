cat 
#fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
fixeldir=/scratch/radv/mtranfa/Fixel_trial

#module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

#iterate across tracts and across metrics the following step
metrics=(fd log_fc fdc) #change based on your metrics of interest, options are fd log_fc fdc

for metric in ${metrics[@]}; do
	mkdir -p ${fixeldir}/tract_stats/${metric}

	for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do
		tract_name=$(basename $path_to_tract)
		if [[ ! -d ${fixeldir}/tract_stats/${metric}/${tract_name} ]]; then
			batch $scriptsdir/make_analysis_tractwise.sh $tract_name $metric 
		else
			"${metric}_smoothed already obtained for ${tract_name}"
		fi
	done
done

echo "Processing is done"



