#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=64G             # max memory per node
# Request 7 hours run time
#SBATCH -t 1-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

tract_name=$1
metric=$2

#obtain fixel wise statistics using the CFE method (using default parameters
fixelconnectivity ${fixeldir}/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/matrix/${tract_name}

if [[ ! -d ${fixeldir}/tract_fixels/${metric}_smoothed ]]; then
	mkdir -p ${fixeldir}/tract_fixels/${metric}_smoothed
fi
fixelfilter ${fixeldir}/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/tract_fixels/${metric}_smoothed/${tract_name} -matrix ${fixeldir}/matrix/${tract_name}

if [[ ! -d ${fixeldir}/tract_stats/${metric} ]]; then
	mkdir -p ${fixeldir}/tract_stats/${metric}
fi

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smoothed/${tract_name} ${fixeldir}/tractwise_statistics_files/files.txt ${fixeldir}/tractwise_statistics_files/design_matrix.txt ${fixeldir}/tractwise_statistics_files/contrast_matrix.txt ${fixeldir}/matrix/${tract_name} ${fixeldir}/tract_stats/${metric}/${tract_name}

#threshold the FWE corrected p-value map to only include fixels with a FWE corrected p-value < .05. This map includes only fixels within the tract showing lower values (pFWE < .05) in the patients group compared to controls
mrthreshold ${fixeldir}/tract_stats/${metric}/${tract_name}/fwe_1mpvalue.mif -abs 0.95 ${fixeldir}/tract_stats/${metric}/${tract_name}/sig_fixels_05.mif

#calculate the average fiber metric for each subject across all fixels that are significantly different between groups
for file_path in ${fixeldir}/tract_fixels/${metric}/${tract_name}/*; do
file=$(basename $file_path)

value=$(mrstats ${fixeldir}/tract_fixels/${metric}/${tract_name}/${file} -mask ${fixeldir}/tract_stats/${metric}/${tract_name}/sig_fixels_05.mif -output mean)

echo "${file%%.*},${metric},${tract_name},${value}" >> ${fixeldir}/tractwise_statistics_files/mean_${metric}.csv


