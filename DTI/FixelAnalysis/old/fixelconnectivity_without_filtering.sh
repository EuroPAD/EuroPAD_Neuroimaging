#!/bin/bash

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

ulimit -n 2048 #do this to avoid OSError: [Errno 24] Too many open files

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

metric="log_fc"

tracts=("interaction_amyloid_immune_on_fc" "main_effect_immune_on_fc" "main_effect_migration_on_fc" "main_effect_amyloid_on_fc" "main_effect_tau_on_fc" "interaction_tau_prsapoe_on_fc" "interaction_tau_amyloid_pathway_on_fc" "interaction_tau_clearance_on_fc")


for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done


metric="fd"

tracts=("main_effect_prsapoe_on_fd" "main_effect_prsnoapoe_on_fd" "main_effect_migration_on_fd" "main_effect_amyloid_pathway_on_fd" "interaction_amyloid_prsapoe_on_fd" "interaction_amyloid_prsnoapoe_on_fd" "interaction_amyloid_clearance_on_fd" "interaction_tau_immune_on_fd" "main_effect_tau_on_fd")

#"main_effect_tau_on_fd" it is still runningh

for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done

metric="fdc"

tracts=("main_effect_prsnoapoe_on_fdc" "main_effect_migration_on_fdc" "main_effect_amyloid_on_fdc" "interaction_amyloid_prsnoapoe_on_fdc" "main_effect_tau_on_fdc")


for tract_name in ${tracts[@]};do
	echo ${tract_name}
	echo ${metric}

	fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} -force 

	fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} -force

done

