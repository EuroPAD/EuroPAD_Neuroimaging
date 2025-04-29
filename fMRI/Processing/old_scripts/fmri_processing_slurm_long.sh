#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50000              # max memory per node
# Request 36 hours run time
#SBATCH -t 36:0:0
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h

# define variables (change according to the system)
rundir=${PWD}  ## where hs been runs (and the log will be saved)
FMRIPREP=/opt/aumc-containers/singularity/fmriprep/fmriprep-21.0.1.sif # fmriprep singularity file
BIDS_DIR=$1 # bids folder
OUTPUT_DIR=$2 # output folder
PARTICIPANT_LABEL=$3 # participant label (without 'sub-')
WORK_DIR=$4 # working directory
FS_LICENSE=/home/radv/llorenzini/license.txt
DENOISE=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI/Processing/denoise-ICAAROMA_FC_LL.py
final_OUTPUT_DIR=$5
ATLAS_FILE=$6
subjectname=$7

module load fsl
module load GCC/9.3.0
module load OpenMPI/4.0.3
module load ANTs/2.3.5

# how to
if [ $# -lt 6 ]; then
	printf "\nHOW TO USE:\n
bash fmriprep.sh bids_folder output_folder participant_label freesurfer_folder working_directory [atlas_file]\n
Notes:
- bids_folder must contain a BIDS-valid dataset (with sub-XXX at the top level)
- output will be saved in output_folder/fmriprep/sub-<participant_label>
- define participant_label without 'sub-'
- working_directory is where temporary files live, make sure you have writing permissions and no space limits 
- final output directory: where to put the data once processing is done
- atlas_file: [optional] brain parcellation in T1w space\n\n"
	exit
fi

#read atlas file
ATLAS_FILE=$6 # ATLAS IN MNI SPACE
ATLAS_NAME=$(basename $ATLAS_FILE)
ATLAS_NAME="${ATLAS_NAME%.*}"
ATLAS_NAME="${ATLAS_NAME%.*}"
printf "\nusing atlas: ${ATLAS_NAME}\n\n"


## Copy subject directory
cp -rf $subjectname $BIDS_DIR


# create output directory if needed
if [ ! -d $OUTPUT_DIR ]; then
	mkdir -p $OUTPUT_DIR
else
	printf "output directory already exists\n\n"
fi

# create working directory if needed
if [ ! -d $WORK_DIR ]; then
	mkdir -p $WORK_DIR
else
	printf "working directory already exists\n\n"
fi


nvisit=`ls -d  ${BIDS_DIR}/sub-${PARTICIPANT_LABEL}/*ses* |wc -l`

# run fmriprep
if [ `ls ${final_OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/ses*/func/sub-${PARTICIPANT_LABEL}_*_task-rest_space-T1w_desc-preproc_bold.nii.gz | wc -l` -eq $nvisit ]; then  #If all visits have been preprocessed / otherwise reprocess whole

	
	printf "fmriprep already done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"
	
	cp -rf ${final_OUTPUT_DIR}/sub-${PARTICIPANT_LABEL} $OUTPUT_DIR # copy the subject into the scratch disk for future processing steps


else
	rm -rf ${WORK_DIR}/* # empty working directory (avoids overlaps with previous executions)
	cp $FS_LICENSE $WORK_DIR		
	printf "starting fmriprep for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"
	singularity run --cleanenv -B $BIDS_DIR -B $OUTPUT_DIR -B $WORK_DIR $FMRIPREP \
	$BIDS_DIR $OUTPUT_DIR participant \
	--skip-bids-validation \
	--participant-label $PARTICIPANT_LABEL \
	--ignore flair \
	--output-spaces T1w \
	--use-aroma \
	--use-syn-sdc \
	--fs-license-file ${WORK_DIR}/license.txt \
	--fs-no-reconall \
	--work-dir $WORK_DIR \
	--longitudinal

fi

printf "fmriprep done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"


## Iterate across visits



for visitfold in `ls -d  ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/*ses*`; do

	ses=`basename $visitfold`; 
	echo $ses; 

	echo "additional processing steps for session $ses"


	if [[ -d ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/$ses/func ]]; then # only if functional was actually acquired
 
		# do nonaggressive AROMA denoising in T1w space
		if [ -f "${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-smoothAROMAnonaggr_bold.nii.gz" ]; then
			printf "nonaggressive AROMA denoising in T1w space already done for sub-${PARTICIPANT_LABEL}\n\n"
		else
			printf "starting nonaggressive AROMA denoising in T1w space for sub-${PARTICIPANT_LABEL} session $ses \n\n"	
			cd ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func
			fsl_regfilt -i sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-preproc_bold.nii.gz -f sub-${PARTICIPANT_LABEL}_${ses}_task-rest_AROMAnoiseICs.csv -d sub-${PARTICIPANT_LABEL}_${ses}_task-rest_desc-MELODIC_mixing.tsv -o sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz

			# create fake smooth file
			cp ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-smoothAROMAnonaggr_bold.nii.gz


		fi


		# put atlas in T1 space

		if [[ $nvisit -eq 1 ]]; then # if only one visit the anat directory will be in the session folder
			antsApplyTransforms -d 3 -i $ATLAS_FILE -r ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/anat/sub-${PARTICIPANT_LABEL}_${ses}_desc-preproc_T1w.nii.gz -o ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_${ATLAS_NAME}.nii.gz -t ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/anat/sub-${PARTICIPANT_LABEL}_${ses}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 -n NearestNeighbor; 
		else  # else in the subject folde 
			antsApplyTransforms -d 3 -i $ATLAS_FILE -r ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/anat/sub-${PARTICIPANT_LABEL}_desc-preproc_T1w.nii.gz -o ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_${ATLAS_NAME}.nii.gz -t ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/anat/sub-${PARTICIPANT_LABEL}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 -n NearestNeighbor;
		fi 
		 

		if [ ! -z ${ATLAS_FILE+x} ]; then
		# do denoising and build functional connectome for the selected atlas
			python3 ${DENOISE} ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-smoothAROMAnonaggr_bold.nii.gz -a ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_${ATLAS_NAME}.nii.gz
			printf "denoising and functional connectome building done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR} and atlas: ${ATLAS_NAME}\n\n"  
		fi # if atlas exists
	fi

done 


rsync -avu --progress --ignore-existing ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL} $final_OUTPUT_DIR/

if [[ -f ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}.html ]]; then

cp -rf ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}.html $final_OUTPUT_DIR/;

fi

rm -rf ${WORK_DIR}
rm -rf ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}*
rm -rf ${BIDS_DIR}/sub-${PARTICIPANT_LABEL}

cd $rundir
mv slurm-${SLURM_JOB_ID}.out $final_OUTPUT_DIR/sub-${PARTICIPANT_LABEL}/


