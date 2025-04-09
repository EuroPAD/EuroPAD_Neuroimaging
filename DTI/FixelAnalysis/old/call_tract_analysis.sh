#!/bin/bash

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2 #uncomment if loading mrtrix is needed

##iterate across tracts and across metrics the following step##

#metrics=(fd log_fc fdc) #change based on your metrics of interest, options are fd log_fc fdc
metric=log_fc
tracts=(CC_7 OR T_OCC ST_OCC POPT IFO ST_PAR T_PAR CC_6)
#PRS=Pt_5e.05whigtman_apoe
PRS=Pt_0.1bellenguez_apoe

#for metric in ${metrics[@]}; do  #uncomment for loop to iterate across metrics
	mkdir -p ${fixeldir}/template/tract_stats/${metric}_${PRS}

	for tract_name in ${tracts[@]}; do 
	
	#for path_to_tract in ${fixeldir}/template/tract_TDIs/*; do #use this for loop if you want to iterate across all tracts
		#tract_name=$(basename $path_to_tract)
		
		if [[ ! -f ${fixeldir}/template/tract_stats/${metric}_${PRS}/${tract_name}/index.mif ]]; then
			echo "computing fixelwise test for ${metric}_${PRS} on ${tract_name}"
			mkdir -p ${fixeldir}/template/tract_stats/${metric}_${PRS}/${tract_name}
			
			#create matrix files if needed
			if [[ ! -f ${fixeldir}/template/matrix/${metric}/${tract_name}/index.mif ]]; then
				mkdir -p ${fixeldir}/template/matrix/${metric}
				fixelconnectivity ${fixeldir}/template/tract_fixels/${metric}/${tract_name} ${fixeldir}/template/tract_files/${tract_name}.tck ${fixeldir}/template/matrix/${metric}/${tract_name} 
			fi
			
			#smooth metrics if needed
			if [[ ! -d ${fixeldir}/template/tract_fixels/${metric}_smooth/${tract_name}/ ]]; then
				mkdir -p ${fixeldir}/template/tract_fixels/${metric}_smooth
			fixelfilter ${fixeldir}/template/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/template/tract_fixels/${metric}_smooth/${tract_name} -matrix ${fixeldir}/template/matrix/${metric}/${tract_name} 
			fi

			if [[ ! -d ${fixeldir}/template/tract_stats/${metric}__${PRS} ]]; then
				mkdir -p ${fixeldir}/template/tract_stats/${metric}_${PRS}
			fi
			
			#add for loop to do all required permutations
			sbatch $scriptsdir/tract_analysis_try.sh ${tract_name} $metric $PRS
		else
			echo "fixelwise test for ${metric}_${PRS} already computed on ${tract_name}"
		fi
	done
#done #uncomment for loop to iterate across metrics

echo "Processing is done"
