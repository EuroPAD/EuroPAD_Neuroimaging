#!/bin/bash
code_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/T1w/MIND/
freesurfer_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1/
MIND_dir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1/

module load Anaconda3/2024.02-1

if [ ! -d ${MIND_dir} ]; then
  mkdir -p ${MIND_dir}
else
  echo "MIND folder already exists"
fi 

# loop over subjects/sessions
cd ${code_dir}

for subjectname in `ls -d ${freesurfer_dir}/sub-*` ; do
i="`basename $subjectname`"
if [ -f ${MIND_dir}/${i} ]; then
  echo "${i} already OK"
else
  echo "computing MIND network for ${i}"
  python3 networks.py ${freesurfer_dir}/${i} -o ${MIND_dir}
fi
done  
