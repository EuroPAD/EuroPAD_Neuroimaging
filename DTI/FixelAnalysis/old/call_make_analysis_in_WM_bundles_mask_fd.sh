#!/bin/bash
module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

cd ${scriptsdir}


for i in {1..500}; do
	echo ${i} 
	sbatch make_analysis_in_WM_bundles_mask_fd.sh ${i}
	
	while [[ $(squeue -u $(whoami) | grep fixel_fd | wc -l) > 0 ]]; do 
		sleep 1; 
	done

done

	



