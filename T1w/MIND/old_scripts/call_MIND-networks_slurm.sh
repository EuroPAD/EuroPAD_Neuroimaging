#!/bin/bash
code_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/MIND
freesurfer_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/FreeSurfer_crossectional
MIND_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/MIND

module load Anaconda3/2022.05

if [ ! -d ${MIND_dir} ]; then
  mkdir -p ${MIND_dir}
else
  echo "MIND folder already exists"
fi 

# loop over subjects/sessions
cd ${code_dir}

for subjectname in `ls -d ${freesurfer_dir}/sub-*` ; do
i="`basename $subjectname`"
if [ -f ${MIND_dir}/${i}_Schaefer400Parcels7Networks ]; then
  echo "${i} already OK"
else
  echo "computing MIND network for ${i}"
  	
	sbatch networks_slurm.sh ${i} ${MIND_dir} ${freesurfer_dir} ${code_dir}
	while [ $(squeue -u $(whoami) | wc -l) == 16 ]; do
		sleep 5;
	done
fi
done  
