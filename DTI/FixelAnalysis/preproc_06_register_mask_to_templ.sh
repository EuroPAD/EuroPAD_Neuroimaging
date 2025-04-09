#!/bin/bash
## Step 6 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Create a list of participants/sessions that do NOT already have a folder in the fixel directory     
#2. Make directories of new subjects in the Fixel Output Directory
#3. Compute transformation from subject to template
#4. apply the transformation to the masks


#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC
singularity=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.19.1.sif


###### Create a list of subjects/sessions that need the registration to template 
echo "Creating list of participants to run registration on"
rm $QCdir/subjects_sessions_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
#echo $subname; 

for ses in `ls -d ${qsirecdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
#echo $ses; 


if [ ! -f $fixeldir/subjects/${subname}/$sesname/dwi/${subname}_${sesname}_to_template.mif ]; then 
	echo ${qsirecdir}/${subname}/$sesname >> $QCdir/subjects_sessions_to_be_processed.txt;
fi; 
done
done

##### Exclude from the list the one from the visual QC 
echo "Cleaning the failed QCs" 
for subname in `cat $QCdir/subjects_to_exclude_from_fixel.txt` ; do 
grep -v $subname $QCdir/subjects_sessions_to_be_processed.txt > tmptxt  ;
mv tmptxt  $QCdir/subjects_sessions_to_be_processed.txt
done 

#### Now Make Subject Folders in the Fixel Output Directory

for sub in `cat $QCdir/subjects_sessions_to_be_processed.txt`; do 

ses=$(basename $sub)
subname=$(basename $(dirname $sub ) )

if [[ ! -d $fixeldir/subjects/${subname} ]]; then 
mkdir $fixeldir/subjects/${subname}; 
fi

if [[ ! -d $fixeldir/subjects/${subname}/${ses} ]]; then 
mkdir $fixeldir/subjects/${subname}/${ses};
fi

if [[ ! -d $fixeldir/subjects/${subname}/${ses}/dwi ]]; then
mkdir $fixeldir/subjects/${subname}/${ses}/dwi ; 
fi

done 

### RUN auxiliary function to compute and apply registration mask --> template 
echo "there are `cat $QCdir/subjects_sessions_to_be_processed.txt | wc -l` subject/sessions to be processed, make sure to adjust the job array script in the auxiliary_functions folder before running..."


sbatch auxiliary_functions/register_mask_to_template.sh  $qsiprepdir $fixeldir $qsirecdir $QCdir



