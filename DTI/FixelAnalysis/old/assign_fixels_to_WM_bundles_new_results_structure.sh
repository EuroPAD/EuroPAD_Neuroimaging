#!/bin/bash

#script to assign significa fixels to specific WM bundles based on TractSeg segmentations#
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
tracts_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_TDIs/
included_tracts=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/
results_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/no_masking_results
csv_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/no_masking_results/results_csv

mkdir $csv_dir

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

for folder in $(ls $results_folder | grep -v results_csv); do #loop across metrics
	echo $folder
	metric=$(ls $results_folder/$folder)
	echo $metric
	predictor=$(ls $results_folder/$folder/$metric)
	echo $predictor
		for result_path in $results_folder/$folder/$metric/$predictor/*/*fwe*; do #loop across tests
			result=$(basename $result_path)
			if [[ $(echo $result | grep t | grep -v permutations) ]]; then
				number=$(echo $result | grep -o '[^t]\+$' | cut -f 1 -d ".") #extract number of the test
				work_dir=$(dirname $result_path)
				csv_file=${work_dir}/significant_fixels_${metric}_${predictor}_t${number}.csv #create csv file to store values
	
				mrthreshold $work_dir/fwe_1mpvalue_t${number}.mif -abs 0.95 $work_dir/thresholded_fixels.mif -force #threshold significant fixels
				value=$(mrstats $work_dir/fwe_1mpvalue_t${number}.mif -mask $work_dir/thresholded_fixels.mif -output count) #total number of significant fixels in results file
				echo ""total_number_of_significant_fixels",${value}" > ${csv_file}

				for i in $(ls $tracts_folder); do #loop across all segmented bundles
					echo $i;
					tck2fixel $included_tracts/${i}.tck $work_dir/ $work_dir/ out.mif -force #from track to fixels using the same fixel grid of the results
					mrcalc $work_dir/out.mif $work_dir/thresholded_fixels.mif -min $work_dir/intersectionmask.mif -force #create intersection maks between fixels of the bundle and thresholded significant fixels
					value=$(mrstats $work_dir/fwe_1mpvalue_t${number}.mif -output count -mask $work_dir/intersectionmask.mif) #count number of significan fixels within mask

					echo "${i},${value}" >> ${csv_file}

				done
				cp $csv_file $csv_dir
				rm $work_dir/out.tck #remove useless files
				rm $work_dir/intersectionmask.mif 
				rm $work_dir/thresholded_fixels.mif 
			fi		
		done
	done
done



