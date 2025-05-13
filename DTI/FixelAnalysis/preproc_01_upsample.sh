#!/bin/bash
## Step 1 of extra processing steps to be done on qsiprep output for performing fixel analysis
#1. Create directories 
#2. Iterate across available DWI and upsample
#
# as this is not hugely computationally expensive, we do not use slurm 
#

# load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

### Settings ###
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fixel_qsirecon_v0.19.0 #outpt fixel directory


#### Make necessary directories if they do not exist #### 

# make directory to store data 
if [[ ! -d ${fixeldir}/subjects ]]; then 
	mkdir ${fixeldir}/subjects; 
fi

# make template directory 
if [[ ! -d ${fixeldir}/template ]]; then 
	mkdir ${fixeldir}/template; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/mask_images ]]; then 
	mkdir ${fixeldir}/mask_images; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/FOD_images ]]; then 
	mkdir ${fixeldir}/FOD_images; 
fi

### Check if upsampled DWI exists and otherwise run ####


# Iterate subjects
for sub in `ls -d ${qsiprepdir}/sub* | grep -v html `; do 

subname=`basename $sub`; 
echo $subname;

# Iterate sessions
for ses in `ls -d ${qsiprepdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
echo $ses;  

if [[ ! -f ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_mask_upsampled.mif ]]; then 

mrconvert ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.nii.gz ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif -fslgrad ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.bvec ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.bval -force
 
#create upsampled DWI
mrgrid ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif regrid -vox 1.25 ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi_upsampled.mif -force

#create upsampled masks
dwi2mask ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi_upsampled.mif ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_mask_upsampled.mif -force

rm ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif

fi
done
done



echo "Upsampling of DWI is complete, please make sure to QC the files before proceeding to the the second step: creating a mean response function (preproc_02_meanresponse.sh)"





