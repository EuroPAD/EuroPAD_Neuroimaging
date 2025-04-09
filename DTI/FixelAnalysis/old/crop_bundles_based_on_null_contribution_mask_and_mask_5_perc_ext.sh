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

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

for metric in ${metrics[@]}; do
	mkdir -p ${fixeldir}/template/tract_fixels/${metric}/
	for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do
	tract_name=$(basename $path_to_tract)
	if [[ ! -d ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ]]; then
		fixelcrop ${fixeldir}/template/${metric} ${fixeldir}/template/tract_TDIs/${tract_name}/${tract_name}_TDI.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}
	fi
	done
done


