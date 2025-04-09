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

#!/bin/bash

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
#fixeldir=/scratch/radv/mtranfa/Fixel_trial

eval "$(conda shell.bash hook)"
conda activate mario #TractSeg is needed

#module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

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
