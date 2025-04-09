#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=38G             # max memory per node
# Request 7 hours run time
#SBATCH -t 7-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

prsofint=("prs_apoe" "prs_noapoe" "pathway1_immuneactiv_noapoe_BA" "pathway2_signaltrasd_noapoe_BA")

metric="fd"

tract_name="all_included_bundles"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

####fd####
echo ${metric}
for prs in ${prsofint[@]};do
	echo ${prs}
	if [[ ${prs} == "prs_apoe" ]];then

		####apoe_prs
		mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}/both_contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd.txt ${fixeldir}/statistics_files/design_matrix_fd_${prs}.txt ${fixeldir}/statistics_files/both_contrasts_fd_prs_apoe.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}/both_contrasts -force

	else
		####noapoe_prs
		mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}/both_contrasts

		fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 12 ${fixeldir}/statistics_files/files_prs_fd_${prs}.txt ${fixeldir}/statistics_files/design_matrix_fd_${prs}.txt ${fixeldir}/statistics_files/both_contrasts_fd_prsnoapoe.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/${prs}/both_contrasts -force
	fi
done



