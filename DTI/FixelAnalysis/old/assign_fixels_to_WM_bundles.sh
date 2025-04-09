#!/bin/bash

#script to assign significa fixels to specific WM bundles based on TractSeg segmentations#
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
tracts_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_TDIs/
included_tracts=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/
results_folder=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/no_masking_results
csv_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_stats/no_masking_results/results_csv

mkdir $csv_dir

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

for metric in $(ls $results_folder | grep fd_smooth); do #loop across metrics
	echo $metric
	for predictor in $(ls $results_folder/$metric); do #loop across predictors
	echo $predictor
		for result_path in $results_folder/$metric/$predictor/*/*fwe*; do #loop across tests
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

#####OLD#####

#threshold significant fixels
#mrthreshold $tryfold/fwe_1mpvalue_t2.mif -abs 0.95 $tryfold/thresholded_fixels.mif -force

#value=$(mrstats $tryfold/fwe_1mpvalue_t2.mif -mask $tryfold/thresholded_fixels.mif -output count)

#for i in $(ls $tracts_folder); do
#echo $i;

#tck2fixel $included_tracts/${i}.tck $tryfold/ $tryfold/ out.mif -force #from track to fixels using the same fixel grid of the results

#mrcalc out.mif thresholded_fixels.mif -min intersectionmask.mif -force #create intersection maks between fixels of the bundle and thresholded significant fixels

#value=$(mrstats $tryfold/fwe_1mpvalue_t2.mif -output count -mask $tryfold/intersectionmask.mif) #count number of significan fixels within mask

#echo "${i},${value}" >> ${csv_file}

#done

#convert fixel to voxel preserving number of significant fixels within each voxel
#fixel2voxel $tryfold/prova.mif sum $tryfold/prova.nii -force
#fixel2voxel $tryfold/prova.mif none $tryfold/prova.nii -force

#value_1=$(tckinfo -count /home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/${i}.tck | grep "actual count" |  grep -o '[^ ]\+$')

#count streamlines that intersect significant voxels for each bundle
#value_2=$(tckinfo -count $tryfold/out.tck | grep "actual count" |  grep -o '[^ ]\+$')

#use the voxel map to filter only significant streamlines from WM bundles ####also a nice way of visualizing significant streamlines####
#tckedit /home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/${i}.tck -include $tryfold/thresholded.nii $tryfold/out.tck -force

#maybe useful#
#mrthreshold fwe_1mpvalue.mif -abs 0.95 - | fixel2voxel - sum - | mrthreshold - -abs 1 any_sig_fixels_in_voxel.mif

#first crop each WM bundle tck using the WM bundle mask used in our study
#mrthreshold /home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_TDIs/all_included_bundles/all_included_bundles_TDI.mif bundles.mif -percentile 0 #create mask of the WM bundles

#mrcalc /home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_TDIs/all_included_bundles/all_included_bundles_TDI.mif 0 -gt bundles.mif -force

#tckedit /home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/tract_files/SLF_I.tck cropped.tck -mask bundles.mif

#convert the cropped tck into mif
#tck2fixel cropped.tck ${fixeldir}/template/fixel_mask . cropped_TDI.mif

#need to create first a binary mask using the TDI files

#mrthreshold fwe_pvalue.mif -abs 0.95 - | mrstats fwe_pvalue.mif -mask - -output count #command to count number of significant fixels

#mrcalc mask1.mif mask2.mif -min intersectionmask.mif #command to create intersection mask




