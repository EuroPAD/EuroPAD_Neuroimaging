#!/bin/bash
#SBATCH --job-name=fixel_fd
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

metric="fd"

tract_name="all_included_bundles"

fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

#make matrix and smooth if needed
#mkdir -p ${fixeldir}/matrix/$metric/${tract_name}

#fixelconnectivity ${fixeldir}/tract_fixels/${metric}/${tract_name} ${fixeldir}/tract_files/${tract_name}.tck ${fixeldir}/matrix/${metric}/${tract_name}
#fixelfilter ${fixeldir}/tract_fixels/${metric}/${tract_name} smooth ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -matrix ${fixeldir}/matrix/${metric}/${tract_name}

####prs_apoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_apoe.txt ${fixeldir}/statistics_files/positive_contrast_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/positive_contrast/*
fi

mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_apoe.txt ${fixeldir}/statistics_files/negative_contrast_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_apoe/negative_contrast/*
fi

####prs_noapoe
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_noapoe.txt ${fixeldir}/statistics_files/positive_contrast_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/positive_contrast/*
fi

mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_prs.txt ${fixeldir}/statistics_files/design_matrix_fd_prs_noapoe.txt ${fixeldir}/statistics_files/negative_contrast_fd_PRS.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/prs_noapoe/negative_contrast/*
fi

####ApTm
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_ApTm.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTm.txt ${fixeldir}/statistics_files/positive_contrast_fd_ApTm.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/positive_contrast/*
fi

mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_ApTm.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTm.txt ${fixeldir}/statistics_files/negative_contrast_fd_ApTm.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTm/negative_contrast/*
fi

####ApTp
mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_ApTp.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTp.txt ${fixeldir}/statistics_files/positive_contrast_fd_ApTp.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/positive_contrast/*
fi

mkdir -p ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/permutations

fixelcfestats ${fixeldir}/tract_fixels/${metric}_smooth_at_tract_level/${tract_name} -nshuffles 10 ${fixeldir}/statistics_files/files_ApTp.txt ${fixeldir}/statistics_files/design_matrix_fd_ApTp.txt ${fixeldir}/statistics_files/negative_contrast_fd_ApTp.txt ${fixeldir}/matrix/${metric}/${tract_name} ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast

if  [[ ${i} != 500 ]]; then
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/null_dist.txt ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/permutations/null_dist_${i}.txt
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/null_contributions.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/permutations/null_contributions_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/uncorrected_pvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/permutations/uncorrected_pvalue_${i}.mif
mv ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/permutations/fwe_1mpvalue_${i}.mif
rm -f ${fixeldir}/tract_stats/${tract_name}/${metric}_smooth/ApTp/negative_contrast/*
fi
