#!/bin/bash
## Step 12 of extra processing steps to be done on qsiprep output for performing fixel analysis

#1. Compute fiber density-cross section (FDC) for every subject
   
#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC

mkdir -p $fixeldir/template/fdc

# make list of subjects to be processed:
echo "Creating list of participants to run registration on"
rm $QCdir/subjects_sessions_to_be_processed.txt
for sub in `ls -d ${fixeldir}/subjects/sub* | grep -v html`; do 
subname=`basename $sub`; 
#echo $subname; 

for ses in `ls -d ${fixeldir}/subjects/${subname}/ses*`; do   

sesname=`basename $ses`;  
#echo $ses; 


if [ ! -f $fixeldir/template/fdc/${subname}_${sesname}.mif ]; then 
	echo ${qsirecdir}/${subname}/$sesname >> $QCdir/subjects_sessions_to_be_processed.txt;
fi; 
done
done


sbatch auxiliary_functions/compute_fdc_array.sh  $qsirecdir $fixeldir $QCdir

