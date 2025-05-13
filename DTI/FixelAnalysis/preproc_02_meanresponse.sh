#!/bin/bash
## Step 2 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Exclude participants based on visual QC performed  
#2. create average response function, only on baseline data
#
#
#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fixel_qsirecon_v0.19.0 #outpt fixel directory
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/DTI/FixelAnalysis/QC

#Initialize empty list
response_files_wm=()
response_files_gm=()
response_files_csf=()


# Check for existing fod files, only in baseline (which could have different naming)
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 

subname=`basename $sub`; 
echo $subname;

# find first session name
sessionfolder=$(ls -d  ${qsirecdir}/$subname/ses* | head -1)
sesname=$(basename $sessionfolder)

if [[ -f ${qsirecdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_desc-wmFOD_ss3tcsd.txt ]]; then 

file_wm=${qsirecdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_desc-wmFOD_ss3tcsd.txt
file_gm=${qsirecdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_desc-gmFOD_ss3tcsd.txt
file_csf=${qsirecdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_desc-csfFOD_ss3tcsd.txt

response_files_wm+=($file_wm)
response_files_gm+=($file_gm)
response_files_csf+=($file_csf)
fi
done

#remove subjects from the arrays based on visual QC
for sub in $(cat $QCdir/subjects_to_exclude_from_fixel.txt); do 
response_files_wm=( $( printf '%s\n' ${response_files_wm[*]} | egrep -v $sub ) ); 
done

for sub in $(cat $QCdir/subjects_to_exclude_from_fixel.txt); do 
response_files_gm=( $( printf '%s\n' ${response_files_gm[*]} | egrep -v $sub ) ); 
done

for sub in $(cat $QCdir/subjects_to_exclude_from_fixel.txt); do 
response_files_csf=( $( printf '%s\n' ${response_files_csf[*]} | egrep -v $sub ) ); 
done

responsemean ${response_files_wm[*]} ${qsirecdir}/group_average_response_wm.txt -force
responsemean ${response_files_gm[*]} ${qsirecdir}/group_average_response_gm.txt -force
responsemean ${response_files_csf[*]} ${qsirecdir}/group_average_response_csf.txt -force
