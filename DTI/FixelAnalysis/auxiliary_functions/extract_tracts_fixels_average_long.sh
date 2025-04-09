#!/bin/bash
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

#iterate across tracts and across metrics the following step
metrics=(fd_smooth_long log_fc_smooth_long fdc_smooth_long) #change based on your metrics of interest, options are fd log_fc fdc

for metric in ${metrics[@]}; do
	csv_file=${fixeldir}/template/mean_${metric}.csv #create csv file to store values
	column_labels="subject_id,fixel_metric,tract,value"
	echo $column_labels > $csv_file
	echo "Currently extracting values for $metric"
	for path_to_tract in ${fixeldir}/template/tract_TDIs_long/*; do
		tract_name=$(basename $path_to_tract)
		echo "Currently extracting values for $tract_name"
		for file_path in ${fixeldir}/template/tract_fixels_long/${metric}/${tract_name}/sub*; do
			file=$(basename $file_path)
			value=$(mrstats ${fixeldir}/template/tract_fixels_long/${metric}/${tract_name}/${file} -output mean)
			echo "${file%%.*},${metric},${tract_name},${value}"
			echo "${file%%.*},${metric},${tract_name},${value}" >> ${csv_file}
		done
	done
done

echo "Processing is done"



