#!/bin/bash
#SBATCH --job-name=fixel_fd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-12:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd#####
metric="fd"

#main effect of prsapoe SLF_I#
tract_name="SLF_I"
analysis_name="main_effect_prsapoe_on_fd"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#main effect of prsnoapoe on SLF_I SLF_II#
tract_name="main_effect_prsnoapoe_on_fd"
analysis_name="main_effect_prsnoapoe_on_fd"
prsofint=("prs_noapoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#main effect of migration on SLF_I SLF_II#
tract_name="main_effect_prsnoapoe_on_fd"
analysis_name="main_effect_migration_on_fd"
prsofint=("pathway4_migration_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#main effect of amyloid pathway on SLF_I#
tract_name="SLF_I"
analysis_name="main_effect_amyloid_pathway_on_fd"
prsofint=("pathway5_amyloid_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#interaction Amyloid*prsapoe on ILF#
tract_name="ILF"
analysis_name="interaction_amyloid_prsapoe_on_fd"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#interaction amyloid*prsnoapoe on ILF#
tract_name="ILF"
analysis_name="interaction_amyloid_prsnoapoe_on_fd"
prsofint=("prs_noapoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done

#interaction amyloid*clearance on ILF#
tract_name="ILF"
analysis_name="interaction_amyloid_clearance_on_fd"
prsofint=("pathway6_cleaning_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_int_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fd_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fd_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${analysis_name}/${metric}_smooth/${prs}_int/contrasts -force
	fi
done
