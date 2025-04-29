#!/bin/bash
## Step 5 of extra processing steps to be done on qsiprep output for performing fixel analysis

#1. Create a fixel template from selected subjects (they have to be representative of your cohort/cohorts)   
#


#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC


### Template Creation from selected subjects
if [ ! -f $fixeldir/template/fod_template.mif ]; then 
	for_each `cat $QCdir/fixel_template_subjects.txt` : cp ${qsirecdir}/IN/ses-01/dwi/IN_ses-01_group_average_response_wmfod_norm.mif $fixeldir/FOD_images 
	for_each `cat $QCdir/fixel_template_subjects.txt` : cp ${qsiprepdir}/IN/ses-01/dwi/IN_ses-01_mask_upsampled.mif $fixeldir/mask_images  
	population_template $fixeldir/FOD_images -mask_dir $fixeldir/mask_images $fixeldir/template/fod_template.mif
	rm -r $fixeldir/FOD_images
else 
	echo "Template has already been done"
fi

