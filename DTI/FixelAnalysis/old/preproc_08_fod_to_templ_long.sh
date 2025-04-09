#!/bin/bash
## Step 8 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Create a list of participants/sessions that do NOT already have the FOD in the template space     
#2. apply the transformation (previously computed with preproc_06) to the FODs


#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC


###### Create a list of subjects/sessions that need the registration to template 
echo "Creating list of participants to run registration on"
rm $QCdir/subjects_sessions_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
#echo $subname; 

for ses in `ls -d ${qsirecdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
#echo $ses; 


if [ ! -f $fixeldir/subjects/${subname}/$sesname/dwi/${subname}_${sesname}_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif ]; then 
	echo ${qsirecdir}/${subname}/$sesname >> $QCdir/subjects_sessions_to_be_processed.txt;
fi; 
done
done


sbatch auxiliary_functions/register_fod_to_template.sh  $qsirecdir $fixeldir $QCdir


