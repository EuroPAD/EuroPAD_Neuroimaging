#!/bin/bash
module load  GCC/9.3.0  OpenMPI/4.0.3  MRtrix/3.0.3-Python-3.8.2

scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template

tract_name="all_included_bundles"

metrics=(log_fc_smooth fd_smooth)

tests=(prs_apoe prs_noapoe ApTm ApTp)

for metric in ${metrics[@]}; do
	for test in ${tests[@]}; do
		echo ${test}

		echo "positive"
		mrmath -keep_unary_axes ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/permutations/fwe_1mpvalue_1.mif mean ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_ongoing_2.mif

		for i in {2..499}; do
			echo ${i} 
			n=$(($i + 1))
	
			mrmath -keep_unary_axes ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_ongoing_${i}.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/permutations/fwe_1mpvalue_${i}.mif mean ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_ongoing_${n}.mif
			rm ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_ongoing_${i}.mif
		done

		mv ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_ongoing_${n}.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/positive_contrast/fwe_1mpvalue_5k_permutations.mif

		echo "negative"
		mrmath -keep_unary_axes ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/permutations/fwe_1mpvalue_1.mif mean ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_ongoing_2.mif

		for i in {2..499}; do
			echo ${i} 
			n=$(($i + 1))
	
			mrmath -keep_unary_axes ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_ongoing_${i}.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/permutations/fwe_1mpvalue_${i}.mif mean ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_ongoing_${n}.mif
			rm ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_ongoing_${i}.mif
		done

		mv ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_ongoing_${n}.mif ${fixeldir}/tract_stats/all_included_bundles/${metric}/${test}/negative_contrast/fwe_1mpvalue_5k_permutations.mif
	done
done


