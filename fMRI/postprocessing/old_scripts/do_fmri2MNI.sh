# Use dual regression ( from an atlas of Resting-state networks ) to extract connectivity and timeseries for a series of preprocessed inputs. 
# this script is supposed to be run after the processing scripts in /fMRI/Processing folder. 
FMRIPREP=/opt/aumc-containers/singularity/fmriprep/fmriprep-21.0.1.sif
derivativesdir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives
fmriprepdir=${derivativesdir}/fmriprep
template=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/MNI4mm.nii.gz

# First warp all fMRI files to 4mm 
for subfold in $(ls -d ${fmriprepdir}/* | grep -v html); do 
	echo $subfold;
	subname=$(basename $subfold); 
	echo $subname

	for sesfold in  $(ls -d ${subfold}/ses*) ; do  
		ses=$(basename $sesfold)
		if [[ ! -f ${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI4mm_AROMAnonaggr_bold.nii.gz ]]; then 

			funcfile=${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz; 
			echo $funcfile
			warpfile=${subfold}/anat/${subname}_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5; 
			echo " Applying ${warpfile} to ${funcfile}"; 
			
			cd ${subfold}/${ses}/anat/
			cm1="singularity exec  $FMRIPREP CompositeTransformUtil --disassemble $warpfile ${subname}_${ses}_from-T1w_to-MNI152NLin6Asym"
			echo $cm1;
			$cm1;
			cm2="antsApplyTransforms -d 3 -e 3 -i $funcfile -r $template -o ${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI4mm_AROMAnonaggr_bold.nii.gz -t 01_${subname}_${ses}_from-T1w_to-MNI152NLin6Asym_DisplacementFieldTransform.nii.gz -n  BSpline -v"; 
			echo $cm2; 
			$cm2;

		fi
	done 
 	
done
