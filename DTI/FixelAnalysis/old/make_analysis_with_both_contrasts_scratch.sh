#!/bin/bash
#SBATCH --job-name=fixel_fc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:30:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

i=$1

metric="log_fc"

tract_name="all_included_bundles"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

#make matrix and smooth if needed
#mkdir -p ${fixeldir}/matrix/$metric/${tract_name}

#fixelconnectivity ${fixeldir}/tract_fixels/${metric}/${tract_name} ${fixeldir}/tract_files/${tract_name}.tck ${fixeldir}/matrix/${metric}/${tract_name}
#fixelfilter ${fixeldir}/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/matrix/${metric}/${tract_name}

####fc#####

####prs_apoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 40 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fc_prs_apoe.txt ${fixeldir}/statistics_files/both_contrasts_fc_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/both_contrasts

####prs_noapoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fc_prs_noapoe.txt ${fixeldir}/statistics_files/both_contrasts_fc_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/both_contrasts

####ApTm
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_ApTm.txt ${fixeldir}/statistics_files/design_matrix_fc_ApTm.txt ${fixeldir}/statistics_files/both_contrasts_fc_ApTm.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/both_contrasts

####ApTp
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_ApTp.txt ${fixeldir}/statistics_files/design_matrix_fc_ApTp.txt ${fixeldir}/statistics_files/both_contrasts_fc_ApTp.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/both_contrasts


####fd####

metric="fd"

####prs_apoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_apoe.txt ${fixeldir}/statistics_files/both_contrasts_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/both_contrasts

####prs_noapoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_noapoe.txt ${fixeldir}/statistics_files/both_contrasts_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/both_contrasts

####ApTm
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_ApTm.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTm.txt ${fixeldir}/statistics_files/both_contrasts_fd_ApTm.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/both_contrasts

####ApTp
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/both_contrasts

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 5000 -nthreads 32 ${fixeldir}/statistics_files/files_ApTp.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTp.txt ${fixeldir}/statistics_files/both_contrasts_fd_ApTp.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/both_contrasts


