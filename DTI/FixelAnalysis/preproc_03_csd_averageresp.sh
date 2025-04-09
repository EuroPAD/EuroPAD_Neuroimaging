#!/bin/bash
## Step 3 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Create a list of participants/sessions that do NOT have the FOD computed on the group average   
#2. Run ss3t constrained spherical deconvolution using the group average to create individuals FOD 
#
# It uses the ss3T csd function from qsiprep singularity as installing Mrtrix3Tissue can be quite problematic
# Since this is quite computanally expensive, we will use slurm and parallelize it


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


# make scratch directory if it does not exist
if [[ ! -d $scratchdir ]]; then 
	mkdir $scratchdir; 
fi



###### Create a list of subjects that need the FOD image estimated from the average response
echo "Creating list of participants to run CSD on"
rm $QCdir/subjects_sessions_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
#echo $subname; 

for ses in `ls -d ${qsirecdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
#echo $ses; 


if [ ! -f ${qsirecdir}/${subname}/$sesname/dwi/${subname}_${sesname}_group_average_response_wmfod.mif ]; then 
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




##### Iterate subjects to be processed. ####
echo "Iterating and slurming single shell 3 tissues CSD"

for file in $(cat $QCdir/subjects_sessions_to_be_processed.txt); do echo $file;  

session=`basename $file`; # extract session

#echo $session;  

subject=`basename $(dirname $file)`;  # subject name

#echo $subject; 

# copy necessary files in the scratch directory


mkdir $scratchdir/${subject}_${session} 

cp ${qsiprepdir}/$subject/$session/dwi/${subject}_${session}_dwi_upsampled.mif $scratchdir/${subject}_${session}/
cp ${qsiprepdir}/$subject/$session/dwi/${subject}_${session}_mask_upsampled.mif $scratchdir/${subject}_${session}/

cd .
sbatch auxiliary_functions/run_sst3_csd.sh $singularity $scratchdir $subject $session $qsirecdir

while [[ $(ls $scratchdir/ | wc -l) = 25 ]]; do

sleep 10;

done


done


