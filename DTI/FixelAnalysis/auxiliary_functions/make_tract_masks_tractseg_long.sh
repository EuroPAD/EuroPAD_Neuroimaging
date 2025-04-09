#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=10G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-02:00:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
#fixeldir=/scratch/radv/mtranfa/Fixel_trial

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

#tract files have already been created for cross-sectional pipeline, so we just need to assign fixels to bundles
#within the longitudinal group mask

#convert tractograms to TDI maps
for path_to_tract in ${fixeldir}/template/tract_files/*; do
tract_complete_name=$(basename $path_to_tract);
tract_name="${tract_complete_name%%.*}"
mkdir -p ${fixeldir}/template/tract_TDIs_long/$tract_name
tck2fixel ${fixeldir}/template/tract_files/${tract_complete_name} ${fixeldir}/template/fixel_mask_long ${fixeldir}/template/tract_TDIs_long/${tract_name}/ ${tract_name}_TDI.mif -nthreads 12
done

#iterate across tracts and across metrics the following step
metrics=(fd_smooth_long log_fc_smooth_long fdc_smooth_long) #change based on your metrics of interest, options are fd_smooth log_fc_smooth fdc_smooth

ulimit -n 4096 #do this to avoid OSError: [Errno 24] Too many open files
#crop the whole brain fixel maps for each subject and for each metric based on the obtained TDI map
for metric in ${metrics[@]}; do
	mkdir -p ${fixeldir}/template/tract_fixels_long/${metric}/
	for path_to_tract in ${fixeldir}/template/tract_TDIs_long/*; do
	tract_name=$(basename $path_to_tract)
	if [[ ! -d ${fixeldir}/template/tract_fixels_long/${metric}/${tract_name} ]]; then
		fixelcrop ${fixeldir}/template/${metric} ${fixeldir}/template/tract_TDIs_long/${tract_name}/${tract_name}_TDI.mif ${fixeldir}/template/tract_fixels_long/${metric}/${tract_name} -nthreads 12
	fi
	done
done

echo "Processing is done"
