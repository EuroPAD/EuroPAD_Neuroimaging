#!/bin/bash
## Step 4 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Create a list of participants/sessions that do NOT have the group average FOD NORMALIZED    
#2. Run asbatch jobarray for running multiple sessions in parallel 
#
#


#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC
singularity=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.19.1.sif
scratchdir=/scratch/radv/llorenzini/FixelCSD  # where to run the csd


###### Create a list of subjects that need the FOD normalization
echo "Creating list of participants to run mtnormalise on"
rm $QCdir/subjects_sessions_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
#echo $subname; 

for ses in `ls -d ${qsirecdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
#echo $ses; 


if [ ! -f ${qsirecdir}/${subname}/$sesname/dwi/${subname}_${sesname}_group_average_response_wmfod_norm.mif ]; then 
	echo ${qsirecdir}/${subname}/$sesname >> $QCdir/subjects_sessions_to_be_processed.txt;
fi; 
done
done



##### Exclude from the list the one from the visual QC 
echo "Cleaning the failed QCs" 
for subname in `cat QC/subjects_to_exclude_from_fixel.txt` ; do 
grep -v $subname $QCdir/subjects_sessions_to_be_processed.txt > tmptxt  ;
mv tmptxt  $QCdir/subjects_sessions_to_be_processed.txt
done 

echo "there are `cat $QCdir/subjects_sessions_to_be_processed.txt | wc -l` subject/sessions to be processed, make sure to adjust the job array script in the auxiliary_functions folder before running..."

sleep 30s

# run jobarray
cd .
sbatch auxiliary_functions/mtnormalise_jobarray.sh $QCdir $qsiprepdir
