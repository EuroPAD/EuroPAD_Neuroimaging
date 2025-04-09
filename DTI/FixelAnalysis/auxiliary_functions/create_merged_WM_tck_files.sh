#!/bin/bash

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

tract_name="main_effect_migration_on_fc"

metric="log_fc"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

tckedit *tck $tract_name.tck #move all files to be merged into the same folder

mkdir -p ${fixeldir}/template/tract_TDIs/$tract_name

tck2fixel ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/fixel_mask ${fixeldir}/template/tract_TDIs/${tract_name} ${tract_name}_TDI.mif

fixelcrop ${fixeldir}/template/${metric} ${fixeldir}/template/tract_TDIs/${tract_name}/${tract_name}_TDI.mif ${fixeldir}/template/tract_fixels/${metric}/${tract_name}

fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force




