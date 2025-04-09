####################################################################################
##created: 16-10-24
##updated: 16-10-24
##purpose: applying MNI transformations to GM masks using the FSL MNI
####################################################################################

module load fsl
module load ANTs

user=$(whoami)
space=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/fastECM/mni/tpl-MNI152NLin6Asym_res-02_T1w.nii.gz ##fsl MNI152NLin6ASym space
derivatives=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fmriprep-v23.0.1
masks=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/fastECM/masks

## temporary file to store individual GM mask paths
subject_mask_list=$masks/MNI_gm_mask_paths.txt
> $subject_mask_list #clear the file before starting

## for loop to get into sub directory
for subject in $(ls -d $derivatives/sub*); do 
	echo $subject;
    sub=$(basename $subject);
    echo $sub

	## for loop to go over each sessions in the subject directory
	for sesfoldpath in $(ls -d ${subject}/ses*) ; do 
		echo $sesfoldpath; 
		ses=$(basename $sesfoldpath); 
		echo $ses;
		
		## Check if the anat folder exists
	    anat_dir=${subject}/${ses}/anat
		if [[ -d $anat_dir ]]; then

	    ## define GM mask file name	
	    subject_mask="${sub}_${ses}_label-GM_probseg_MNI152NLin6Asym.nii.gz"
        echo $subject_mask
		gm_mask_file=${anat_dir}/${sub}_${ses}_label-GM_probseg.nii.gz
		transform_file=${anat_dir}/${sub}_${ses}_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5
		output_file=${anat_dir}/${sub}_${ses}_label-GM_probseg_MNI152NLin6Asym.nii.gz

		## Check if the GM mask file exists in the anat folder
	    if [[ -f $gm_mask_file ]]; then
	        echo "anat folder and GM mask file exist, processing subject: $sub, session: $ses"

	    ## conditional staments to check if GM mask already exists in the MNILin6 space, if not, first apply transform and then add them to make the mask
		if [[ ! -e $anat_dir/$subject_mask ]]; then			
		    echo "no subject mask, Applying MNI transformation"

		    ## apply ants transform (T1w to MNILin6)
            antsApplyTransforms -i $gm_mask_file -t $transform_file -o $output_file -r $space -n NearestNeighbor 

		    ## add generated mask to the list
		    echo $subject_mask
		    echo "${anat_dir}/$subject_mask" >> $subject_mask_list
	    else 
		    echo "GM MNI mask already available"
		    ## add available mask to the list
		    echo $subject_mask			
		    echo "${anat_dir}/$subject_mask" >> $subject_mask_list
	    fi
		else
			 echo "GM mask file not found in anat folder, skipping session: $ses"
		fi
		else
	    	echo "No anat folder found for session: $ses, skipping"
		fi
	        cd $derivatives
            
    done
done