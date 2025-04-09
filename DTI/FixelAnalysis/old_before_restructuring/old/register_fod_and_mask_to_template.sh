#!/bin/bash
#SBATCH --job-name=register_fod
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=5G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:30:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

subject=$1
sub=`basename $subject`
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

# Compute the transformation (mrregister) of the WM FOD to the group template 
mrregister ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif -mask1 ${qsiprepdir}/${sub}/ses-01/dwi/${sub}_ses-01_mask_upsampled.mif $fixeldir/template/fod_template.mif -nl_warp $fixeldir/subjects/${sub}/ses-01/dwi/${sub}_to_template.mif $fixeldir/subjects/${sub}/ses-01/dwi/template_to_${sub}.mif -f

# Apply the computed transformation to the masks
mrtransform ${qsiprepdir}/${sub}/ses-01/dwi/${sub}_ses-01_mask_upsampled.mif -warp $fixeldir/subjects/${sub}/ses-01/dwi/${sub}_to_template.mif -interp nearest $fixeldir/subjects/${sub}/ses-01/dwi/${sub}_ses-01_space-FODtemplate_brain_mask.mif -force

rm -d $scriptsdir/subjects/$sub

if [[ -f $fixeldir/subjects/${sub}/ses-01/dwi/${sub}_ses-01_space-FODtemplate_brain_mask.mif ]]; then 
	echo  "${sub}_ses-01 is OK" >> $scriptsdir/check_registration.txt; 
else
	echo  "${sub}_ses-01 is not OK" >> $scriptsdir/check_registration.txt; 
fi
