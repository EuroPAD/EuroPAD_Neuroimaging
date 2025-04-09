#!/bin/bash
#SBATCH --job-name=upsample_dwi
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=8G             # max memory per node
# Request 7 hours run time
#SBATCH -t 1-00:0:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario
fixelscriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
#QSIPREP=/home/radv/mtranfa/qsiprep-0.19.0.sif

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

###Check if upsampled DWI exists
#for sub in `ls -d ${qsiprepdir}/sub* | grep -v html`; do 
for sub in $(cat ${fixelscriptsdir}/subjects_with_only_ses-02.txt); do 

#subname=`basename $sub`; 
subname=$sub; 
echo $subname;

sesname=ses-02
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
