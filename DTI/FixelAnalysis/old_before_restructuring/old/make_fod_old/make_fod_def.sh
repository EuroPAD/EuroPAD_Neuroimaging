#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=3G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-04:00:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

subject=$1
sub=`basename $subject`
qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

echo "currently processing $sub"
#compute FOD images using average response #MRtrix3Tissue is needed here https://3tissue.github.io/doc/

if [[ ! -f ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod.mif ]]; then 
ss3t_csd_beta1 ${qsiprepdir}/${sub}/ses-01/dwi/${sub}_ses-01_dwi_upsampled.mif ${qsirecdir}/group_average_response_wm.txt ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod.mif ${qsirecdir}/group_average_response_gm.txt ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_gm.mif ${qsirecdir}/group_average_response_csf.txt ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_csf.mif -mask ${qsiprepdir}/${sub}/ses-01/dwi/${sub}_ses-01_mask_upsampled.mif -force;
else
	echo "FOD already done for $sub"
fi

echo "now running mtnormalise on $sub"
#joint bias field correction and intensity normalization
if [[ ! -f ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif ]]; then 
mtnormalise ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod.mif ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_gm.mif ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_gm_norm.mif ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_csf.mif ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_csf_norm.mif -mask ${qsiprepdir}/${sub}/ses-01/dwi/${sub}_ses-01_mask_upsampled.mif -force
else
	echo "FOD normalization already done for $sub"
fi

if [[ -f ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif ]]; then 
	echo  "${sub}_ses-01 is OK" >> $scriptsdir/check_fod.txt; 
else
	echo  "${sub}_ses-01 is not OK" >> $scriptsdir/check_fod.txt; 
fi
rm -d $scriptsdir/subjects/$sub

