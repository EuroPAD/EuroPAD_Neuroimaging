qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

for subject in $(cat $scriptsdir/subjects_to_be_processed.txt); do 
echo $subject;
sub=`basename $subject`
if [[ ! -f $fixeldir/subjects/${sub}/ses-01/dwi/${sub}_ses-01_space-FODtemplate_brain_mask.mif ]]; then
	echo "Processing $sub"
	sbatch $scriptsdir/register_fod_and_mask_to_template.sh $subject
	mkdir -p $scriptsdir/subjects/$sub

	#while [[ $(ls $scriptsdir/subjects/ | wc -l) = 10d ]]; do
	while [ $(squeue -u $(whoami) | wc -l) == 11 ]; do
		sleep 5;
	done
else
	echo "$sub has been already processed"
fi
done
