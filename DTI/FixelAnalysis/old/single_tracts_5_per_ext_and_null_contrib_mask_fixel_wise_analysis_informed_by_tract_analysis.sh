#!/bin/bash
#SBATCH --job-name=not_fixel_fc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 6-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

###script to run fixel-wise analysis within selected WM tracts based on the previous tract-level analysis###
###it requires some manual steps to merge the bundles' tck files with tckedit before running this analysis###

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fc#####
metric="log_fc"

#main effect of migration pathway on SLF_I SLF_II CC_2 CC_3 CC_4 ATR CG#
tracts=("ATR" "CC_2" "CC_3" "CC_4" "CG" "SLF_I" "SLF_II")
analysis_name="main_effect_migration_on_fc"
prsofint=("pathway4_migration_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}

		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

		mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

		mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		fi
	done
done

#main effect of amyloid on ATR CG#
tracts=("ATR" "CG")
analysis_name="main_effect_amyloid_on_fc"
prsofint=("prs_apoe")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}

		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

		mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

		mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		fi
	done
done

#interaction amyloid*immune on CST SLF_III#
tracts=("CST" "SLF_III")
analysis_name="interaction_amyloid_immune_on_fc"
prsofint=("pathway1_immuneactiv_noapoe_BA")

for tract_name in ${tracts[@]};do
	echo ${metric}
	echo ${tract_name}
	echo ${analysis_name}
	for prs in ${prsofint[@]};do
		output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
		echo ${prs}

		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

		mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
		mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

		mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

		if [[ ${prs} == "prs_apoe" ]];then

			####apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		else
			####no_apoe_prs
			mkdir -p ${output_dir}

			fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

		fi
	done
done

#main effect of tau on CG#
tract_name="CG"
analysis_name="main_effect_tau_on_fc"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

	mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	else
		####no_apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	fi
done


#interaction tau*prsapoe on AF#
tract_name="AF"
analysis_name="interaction_tau_prsapoe_on_fc"
prsofint=("prs_apoe")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

	mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	else
		####no_apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	fi
done

#interaction tau*amyloid pathway on MLF#
tract_name="MLF"
analysis_name="interaction_tau_amyloid_pathway_on_fc"
prsofint=("pathway5_amyloid_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

	mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	else
		####no_apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	fi
done

#interaction tau*clearance on CC_2#
tract_name="CC_2"
analysis_name="interaction_tau_clearance_on_fc"
prsofint=("pathway6_cleaning_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

	mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	else
		####no_apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	fi
done

#main effect of immune pathway on MLF#
tract_name="MLF"
analysis_name="main_effect_immune_on_fc"
prsofint=("pathway1_immuneactiv_noapoe_BA")

echo ${metric}
echo ${tract_name}
echo ${analysis_name}
for prs in ${prsofint[@]};do
	output_dir=${fixeldir}/tract_stats/results_null_distribution_and_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts
	echo ${prs}

	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/null_contributions* sum ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif -keep_unary_axes -force

	mrthreshold -abs 5 -invert ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/sum_null_contributions.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif -force #make mask to exclude the fixels that have a stronger partecipation to null_contributions
	
	mrmath ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contributions.mif ${fixeldir}/tract_fixels/${metric}/${tract_name}/extent_mask.mif mean ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif -keep_unary_axes -force

	mrthreshold -abs 1 ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mean_null_contrib_5_perc_ext.mif ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force #exclude the fixels that show a smaller degree of connectivity (otherwise their t-statistic will be falsely enhanced by cfe)

	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fc_int.txt ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prs_apoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	else
		####no_apoe_prs
		mkdir -p ${output_dir}

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_int_fc_${prs}.txt  ${fixeldir}/statistics_files/design_matrix_fc_${prs}_int.txt ${fixeldir}/statistics_files/contrasts_fc_prsnoapoe_int.txt ${fixeldir}/matrix/${metric}/${tract_name} ${output_dir} -mask ${fixeldir}/tract_stats/results_5_perc_ext_mask_single_bundles/${analysis_name}/${metric}_smooth/${prs}_int/${tract_name}/contrasts/mask_null_contrib_5_perc_ext.mif -force

	fi
done


