# Script to apply MNI transformation to subject brain masks

module load ANTs
module load fsl/6.0.7.6

reference=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz

derivatives=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1

for sub in `ls -d $derivatives/sub-EPAD* | grep -v .html`; do 
	sub=$(basename $sub)
	printf "\nSubject $sub...\n"
	
	for ses in `ls -d $derivatives/$sub/ses-0*`; do
		session=$(basename $ses)
		printf "  $session...\n"
		transform=$derivatives/$sub/$session/anat/${sub}_${session}_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5
		input=$derivatives/$sub/$session/anat/${sub}_${session}_desc-brain_mask.nii.gz
		output=$derivatives/$sub/${session}/func/${sub}_${session}_space-MNI152NLin6Asym-brain_mask.nii.gz 
		if [ -f $output ]; then
			echo "    Transform already computed..."
		elif [[ -f $transform && -f $input ]]; then
			printf "    Computing transform...\n"
			antsApplyTransforms -i $input -t $transform -o $output -r $reference -n NearestNeighbor; 
		else 
			printf "    Some files are missing, cannot compute transformations...\n"
		fi

		fmri=$derivatives/$sub/${session}/func/${sub}_${session}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
		fmri_masked=$derivatives/$sub/${session}/func/${sub}_${session}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask.nii.gz

		if [ -f $fmri_masked ]; then
			echo "    Mask already applied to rs-fMRI..."
		elif [ -f $fmri ]; then
			printf "    Applying mask to rs-fMRI...\n"
			# fslmaths input -operations (operations input) output
			fslmaths $fmri -mul $output $fmri_masked
		else
			printf "    No rs-fMRI file found...\n"
		fi
	done
done


printf "Script finished!\n\n"
