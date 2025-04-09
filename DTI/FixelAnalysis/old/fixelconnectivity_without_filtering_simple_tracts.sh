#!/bin/bash

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

metric="log_fc"

tracts=("CG" "AF" "MLF" "CC_2")


for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done


metric="fd"

tracts=("ILF" "SLF_I")


for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done

metric="fdc"

tracts=("SLF_II" "ILF")


for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done

