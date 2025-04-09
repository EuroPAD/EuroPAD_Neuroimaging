derivativesdir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives
fmriprepdir=${derivativesdir}/fmriprep
outputfold=${derivativesdir}/fastECM
mask=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI/fastECM/EPAD_mask_2mm.nii.gz # apriori mask  we should make our own
atlas=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/schaeffer_100_2mm.nii.gz
fastECMdir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/scripts_from_dev1/bias/matlab/fastECM

if  [[ ! -d $outputfold ]]; then
	mkdir -p $outputfold; 
fi 

cd $fastECMdir

for subfold in $(ls -d ${fmriprepdir}/* | grep -v html); do 
	echo $subfold;
	subname=$(basename $subfold); 
	echo $subname

	for sesfold in $(ls -d ${subfold}/ses*) ; do  
		ses=$(basename $sesfold); 
		echo $ses; 

		if [[ -f ${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI152Nlin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz ]]; then  
			
			funcfile=${subfold}/${ses}/func/${subname}_${ses}_task-rest_space-MNI152Nlin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz; 
			
			# only if it has not been run already
			if [[ -d $outputfold/$subname/$ses ]]; then 
				echo "fastECM already run for subject ${subname} session ${ses}; delete to rerun" ; 
			else 
				mkdir -p $outputfold/$subname/$ses/voxelwise ;
				mkdir -p $outputfold/$subname/$ses/atlas; 

				cp $funcfile $outputfold/$subname/$ses/voxelwise/;
				cp $funcfile $outputfold/$subname/$ses/atlas/;
				
				#voxelwise extraction
				newfunc=$outputfold/$subname/$ses/voxelwise/${subname}_${ses}_task-rest_space-MNI152Nlin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz;
				matlab -nodesktop -nosplash -r "op.inputfile='$newfunc'; op.degmap=1; op.maskfile='$mask'; fastECM(op); quit "
			
				#atlas extraction
				newfunc=$outputfold/$subname/$ses/atlas/${subname}_${ses}_task-rest_space-MNI152Nlin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz;
				matlab -nodesktop -nosplash -r "op.inputfile='$newfunc'; op.degmap=1; op.maskfile='$mask'; op.atlasfile='$atlas'; fastECM(op); quit "
				
				rm $outputfold/$subname/$ses/${subname}_${ses}_task-rest_space-MNI152Nlin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
			fi
		fi 

	done 
done 
