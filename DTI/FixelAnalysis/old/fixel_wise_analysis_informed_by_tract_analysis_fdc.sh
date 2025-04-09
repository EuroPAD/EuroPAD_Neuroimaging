#!/bin/bash
#SBATCH --job-name=fixel_fdc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=30G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fdc#####
metric="fdc"

#main effect of prs_noapoe on SLF_II#
tract_name="SLF_II"
analysis_name="main_effect_prsnoapoe_on_fdc"
prsofint=("prs_noapoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	else
		####no_apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	fi
done

#main effect of migration on SLF_I SLF_II CST CG CC_2 CC_3 CC_4 ATR AF#
tract_name="main_effect_migration_on_fdc"
analysis_name="main_effect_migration_on_fdc"
prsofint=("pathway4_migration_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	else
		####no_apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	fi
done

#main effect of amyloid on CG ILF#
tract_name="main_effect_amyloid_on_fdc"
analysis_name="main_effect_amyloid_on_fdc"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	else
		####no_apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	fi
done

#interaction amyloid*prsnoapoe on ILF#
tract_name="ILF"
analysis_name="interaction_amyloid_prsnoapoe_on_fdc"
prsofint=("prs_noapoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	else
		####no_apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	fi
done

#main effect of tau on CC_2 CC_4#
tract_name="main_effect_tau_on_fdc"
analysis_name="main_effect_tau_on_fdc"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	else
		####no_apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -mask ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif -force

	fi
done

#prsofint=("prs_apoe" "prs_noapoe" "pathway1_immuneactiv_noapoe_BA" "pathway2_signaltrasd_noapoe_BA" "pathway3_inflammatory_noapoe_BA" "pathway4_migration_noapoe_BA" "pathway5_amyloid_noapoe_BA" "pathway6_cleaning_noapoe_BA")

#metric="fdc"
#echo ${metric}
#for prs in ${prsofint[@]};do
	#echo ${prs}
	#if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
	#	mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts

		#fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts -force
	#else
		####noapoe_prs
		#mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts

		#fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}_int/contrasts -force
	#fi
#done


