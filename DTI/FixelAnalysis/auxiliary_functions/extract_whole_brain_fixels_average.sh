fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

#iterate across tracts and across metrics the following step
metrics=(fd log_fc fdc) #change based on your metrics of interest, options are fd log_fc fdc

for metric in ${metrics[@]}; do
	csv_file=${fixeldir}/template/mean_wb_${metric}.csv #create csv file to store values
	column_labels="subject_id,fixel_metric,value"
	echo $column_labels > $csv_file
	echo "Currently extracting values for $metric"
	#for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do
		#tract_name=$(basename $path_to_tract)
		#echo "Currently extracting values for $tract_name"
	for file_path in ${fixeldir}/template/${metric}/sub*; do
			file=$(basename $file_path)
			value=$(mrstats ${fixeldir}/template/${metric}/${file} -output mean)

			echo "${file%%.*},${metric},${value}" >> ${csv_file}
		done
	done
done

echo "Processing is done"



