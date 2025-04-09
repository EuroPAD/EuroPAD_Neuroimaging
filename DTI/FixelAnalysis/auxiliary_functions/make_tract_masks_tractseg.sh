#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=30G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-06:00:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
#fixeldir=/scratch/radv/mtranfa/Fixel_trial

eval "$(conda shell.bash hook)"
conda activate mario #TractSeg is needed

#module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

#create tck files using TractSeg
sh2peaks ${fixeldir}/template/fod_template.mif ${fixeldir}/template/peaks.nii.gz -force
flip_peaks -i ${fixeldir}/template/peaks.nii.gz -o ${fixeldir}/template/peaks_flip_x.nii.gz -a x
TractSeg -i ${fixeldir}/template/peaks_flip_x.nii.gz -o ${fixeldir}/template/ --output_type tract_segmentation
TractSeg -i ${fixeldir}/template/peaks_flip_x.nii.gz -o ${fixeldir}/template/ --output_type endings_segmentation
TractSeg -i ${fixeldir}/template/peaks_flip_x.nii.gz -o ${fixeldir}/template/ --output_type TOM
ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files
Tracking -i ${fixeldir}/template/peaks_flip_x.nii.gz -o ${fixeldir}/template/ --tracking_format tck --nr_fibers 10000

#iterate across tracts and across metrics the following step
metrics=(fd_smooth log_fc_smooth fdc_smooth) #change based on your metrics of interest, options are fd_smooth log_fc_smooth fdc_smooth

#combine tractograms across hemispheres and move tck to tract_files folder for subsequent steps
mkdir -p ${fixeldir}/template/split_tracts/
mkdir -p ${fixeldir}/template/tract_files/
for path_to_tract in ${fixeldir}/template/TOM_trackings/*; do
tract_complete_name=$(basename $path_to_tract)
tract=$(echo "$tract_complete_name" | sed 's/_[^_]*$//g')
#side=left

if [[ -f ${fixeldir}/template/TOM_trackings/${tract}_left.tck && -f ${fixeldir}/template/TOM_trackings/${tract}_right.tck ]]; then
	echo "Left and right side files exist for $tract"
	#if [[ "$tract_complete_name" == *$side* ]]; then
		#echo "Tract side matches: $side"
		if [[ ! -f ${fixeldir}/template/tract_files/${tract}.tck ]]; then
			echo "Combined file does not exist for $tract"
  			tckedit ${fixeldir}/template/TOM_trackings/${tract}_left.tck ${fixeldir}/template/TOM_trackings/${tract}_right.tck ${fixeldir}/template/tract_files/${tract}.tck
			cp ${fixeldir}/template/TOM_trackings/${tract}_left.tck ${fixeldir}/template/split_tracts/
			cp ${fixeldir}/template/TOM_trackings/${tract}_right.tck ${fixeldir}/template/split_tracts/
		else 
			echo "combined file is already done for ${tract}"
		fi
	#else
		#echo "Tract side does not match: $tract_side"
	#fi
else	
	echo "Either left or right side file is missing for $tract"
	cp ${fixeldir}/template/TOM_trackings/${tract_complete_name} ${fixeldir}/template/tract_files/
fi
done

#convert tractograms to TDI maps
for path_to_tract in ${fixeldir}/template/tract_files/*; do
tract_complete_name=$(basename $path_to_tract);
tract_name="${tract_complete_name%%.*}"
mkdir -p ${fixeldir}/template/tract_TDIs/$tract_name
tck2fixel ${fixeldir}/template/tract_files/${tract_complete_name} ${fixeldir}/template/fixel_mask ${fixeldir}/template/tract_TDIs/${tract_name}/ ${tract_name}_TDI.mif
done

#crop the whole brain fixel maps for each subject and for each metric based on the obtained TDI map
for metric in ${metrics[@]}; do
	mkdir -p ${fixeldir}/template/tract_fixels/${metric}/
	for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do
	tract_name=$(basename $path_to_tract)
	if [[ ! -d ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ]]; then
		fixelcrop ${fixeldir}/template/${metric} ${fixeldir}/template/tract_TDIs/${tract_name}/${tract_name}_TDI.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}
	fi
	done
done

echo "Processing is done"
