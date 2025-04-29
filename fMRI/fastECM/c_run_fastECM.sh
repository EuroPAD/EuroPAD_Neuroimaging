####################################################################################
##created: 07-10-24
##updated: 07-10-24
##purpose: run voxel-wise and atlas based fastECM per each subject and session in the directory
####################################################################################

module load matlab

##specify directories
user=$(whoami)
derivativesdir=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives
fmriprepdir=${derivativesdir}/fmriprep-v23.0.1
outputfold=${derivativesdir}/fastECM
atlas=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR.nii.gz #atlas in neurological space for consistency
mask=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/fastECM/masks/groupmask_label-GM_probseg_MNI152NLin6Asym_0.2_thr_bin.nii.gz # apriori mask  we should make our own
fastECMdir=/home/radv/$user/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/fMRI/fastECM/bias/matlab/fastECM

##if no fastECM output directory available, then make output directory
if  [[ ! -d $outputfold ]]; then
	mkdir -p $outputfold; 
fi 

##navigate to the master fastECM folder with matlab function
cd $fastECMdir

##loop through all subjectss in fmriprep directory
for subfold in $(ls -d ${fmriprepdir}/sub* | grep -v html); do 
	echo $subfold;
	subname=$(basename $subfold); 
	echo $subname

	##loop through all the sessions folder
	for sesfold in $(ls -d ${subfold}/ses*) ; do 
		echo $sesfold;
		ses=$(basename $sesfold); 
		echo $ses;
		
		##check of there is a fmri bold image and allocate it to funcfile
		if [[ -f ${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz ]]; then  
			
			funcfile=${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz; 
			
			# only if it has not been run already
			if [[ -d $outputfold/$subname/$ses ]]; then 
				echo "fastECM already run for subject ${subname} session ${ses}; delete to rerun" ; 
			else 
				##make output directories and copy the input file to the output directory to run fastECM				
				mkdir -p $outputfold/$subname/$ses/voxelwise ;
				mkdir -p $outputfold/$subname/$ses/atlas; 

				ln -sf $funcfile $outputfold/$subname/$ses/voxelwise/;
				ln -sf $funcfile $outputfold/$subname/$ses/atlas/;
				
				#voxelwise extraction
				newfunc=$outputfold/$subname/$ses/voxelwise/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz;
				matlab -nodesktop -nosplash -r "op.inputfile='$newfunc'; op.degmap=1; op.maskfile='$mask'; fastECM(op); quit "
			
				#atlas extraction
				newfunc=$outputfold/$subname/$ses/atlas/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz;
				matlab -nodesktop -nosplash -r "op.inputfile='$newfunc'; op.degmap=1; op.maskfile='$mask'; op.atlasfile='$atlas'; fastECM(op); quit "

				##remove the fmri bold image from the outpur directories
				rm $outputfold/$subname/$ses/voxelwise/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
				rm $outputfold/$subname/$ses/atlas/${subname}_${ses}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
			fi
		fi 

	done 
done 