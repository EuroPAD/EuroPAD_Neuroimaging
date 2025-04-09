#!/bin/bash

#module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

conda activate mrtrixdev #use mrtrix dev version to filter fixels based on fixel-fixel connectivity extent

export PATH=/home/radv/mtranfa/mrtrix3_dev_prova/mrtrix3/bin/:"$PATH"

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

tracts=$(ls $fixeldir/template/tract_fixels/fd_smooth | grep -v all_included_bundles)

metric="log_fc"

for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force -extent ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif

	mrthreshold -percentile 5 ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -mask ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

done

metric="fd"

for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force -extent ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif

	mrthreshold -percentile 5 ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -mask ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

done

metric="fdc"

for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force -extent ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif

	mrthreshold -percentile 5 ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -mask ${fixeldir}/template/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

done

