module load fsl/6.0.7.6

qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis
scratch=/home/radv/mtranfa/my-scratch
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels

mkdir $scratch/qc_mask_images

for subject in $(ls -d $fixeldir/subjects/*); do 
echo $subject;
sub=`basename $subject`

if [ -f ${fixeldir}/subjects/${sub}/ses-01/dwi/*space-FODtemplate_brain_mask.mif ] && [[ ! -f $scratch/qc_mask_images/${sub}_ses-010000.png ]]; then

	mrview ${fixeldir}/subjects/${sub}/ses-01/dwi/*space-FODtemplate_brain_mask.mif -mode 2 -capture.folder $scratch/qc_mask_images/ -capture.prefix ${sub}_ses-01 -capture.grab -exit 

else 
	echo "qc image already done for $sub"
fi
done

