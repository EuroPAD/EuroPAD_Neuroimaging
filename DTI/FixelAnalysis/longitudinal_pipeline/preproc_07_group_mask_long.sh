#!/bin/bash
## Step 7 of extra processing steps to be done on qsiprep output for performing fixel analysis
# 1. if it does not already exist, create intersection of all masks in template space. If it exist, exit
# 2. 


#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC
singularity=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.19.1.sif

# create mask intersection if it does not exist
if [[ ! -f $fixeldir/template/group_mask_intersection_long.mif ]] ; then
# Take the intersection of the masks and create a group mask
mrmath $fixeldir/subjects/*/ses-*/dwi/sub*space-FODtemplate_brain_mask.mif min $fixeldir/template/group_mask_intersection_long.mif -datatype bit 

else

echo "mask intersection exist in the fixel directory, we will not recompute it" 

fi

# Compute fixels on group template within the group mask
if [[ ! -d  $fixeldir/template/fixel_mask_long ]]; then 
fod2fixel -mask $fixeldir/template/group_mask_intersection_long.mif -fmls_peak_value 0.06 $fixeldir/template/fod_template.mif $fixeldir/template/fixel_mask_long # do fixels on template
else 
echo "fod2fixel already run on template, we will not re-run it " 

fi 

