#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16000              # max memory per node
# Request 36 hours run time
#SBATCH -t 36:0:0
#SBATCH --nice=100			# be nice
#SBATCH --partition=rng-long  # rng-short is default, but use rng-long if time exceeds 7h

## modules 
module load ants/2.3.5
module load fsl/6.0.4



# define variables (change according to the system)
rundir=${PWD}  # directory from where it is run  (and the log is created)))
FMRIPREP=/store/singularity_images/fmriprep-21.0.1.sif # fmriprep singularity file
BIDS_DIR=$1 # bids folder
OUTPUT_DIR=$2 # output folder
PARTICIPANT_LABEL=$3 # participant label (without 'sub-')
WORK_DIR=$4 # working directory
FS_LICENSE=/opt/amc/freesurfer-7.1.1/license.txt
DENOISE=/home/llorenzini/lood_storage/divi/Projects/ExploreASL/Twins/Twins_bids/scripts/fMRI/denoise-ICAAROMA_FC_LL.py
final_OUTPUT_DIR=$5
ses=$7

# how to
if [ $# -lt 7 ]; then
	printf "\nHOW TO USE:\n
bash fmriprep.sh bids_folder output_folder participant_label freesurfer_folder working_directory [atlas_file]\n
Notes:
- bids_folder must contain a BIDS-valid dataset (with sub-XXX at the top level)
- output of the pipeline will be initially saved and put in  
- define participant_label without 'sub-'
- working_directory is where temporary files live, make sure you have writing permissions and no space limits 
- final output directory: where to put the data once processing is done
- atlas_file: [optional] brain parcellation in T1w space\n\n
- session to be processed (e.g. session 1), this is because we do cross sectional processing"
	exit	
fi


# read atlas
ATLAS_FILE=$6 # ATLAS IN MNI SPACE
ATLAS_NAME=$(basename $ATLAS_FILE)
ATLAS_NAME="${ATLAS_NAME%.*}"
ATLAS_NAME="${ATLAS_NAME%.*}"

printf "\nusing atlas: ${ATLAS_NAME}\n\n"



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


# run fmriprep
if [ -f "${final_OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-preproc_bold.nii.gz" ]; then

	
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
	--work-dir $WORK_DIR
fi

printf "fmriprep done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"

# do nonaggressive AROMA denoising in T1w space
if [ -f "${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz" ]; then
	printf "nonaggressive AROMA denoising in T1w space already done for sub-${PARTICIPANT_LABEL}\n\n"
else
	printf "starting nonaggressive AROMA denoising in T1w space for sub-${PARTICIPANT_LABEL}\n\n"	
	cd ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func
	fsl_regfilt -i sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-preproc_bold.nii.gz -f sub-${PARTICIPANT_LABEL}_${ses}_task-rest_AROMAnoiseICs.csv -d sub-${PARTICIPANT_LABEL}_${ses}_task-rest_desc-MELODIC_mixing.tsv -o sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz




fi

# create fake smooth file
cp ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-AROMAnonaggr_bold.nii.gz ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-smoothAROMAnonaggr_bold.nii.gz
# put atlas in T1 space
antsApplyTransforms -d 3 -i $ATLAS_FILE -r ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/anat/sub-${PARTICIPANT_LABEL}_${ses}_desc-preproc_T1w.nii.gz -o ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_${ATLAS_NAME}.nii.gz -t ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/anat/sub-${PARTICIPANT_LABEL}_${ses}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 -n NearestNeighbor 

if [ ! -z ${ATLAS_FILE+x} ]; then
# do denoising and build functional connectome for the selected atlas
	python3 ${DENOISE} ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_desc-smoothAROMAnonaggr_bold.nii.gz -a ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/${ses}/func/sub-${PARTICIPANT_LABEL}_${ses}_task-rest_space-T1w_${ATLAS_NAME}.nii.gz
	printf "denoising and functional connectome building done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR} and atlas: ${ATLAS_NAME}\n\n"  
fi # if atlas exists


rsync -avu --progress --ignore-existing ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL} $final_OUTPUT_DIR/

if [[ -f ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}.html ]]; then

cp -rf ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}.html $final_OUTPUT_DIR/;

fi

rm -rf ${WORK_DIR}
rm -rf ${OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}*
rm -rf ${BIDS_DIR}/sub-${PARTICIPANT_LABEL}

cd $rundir
mv slurm-${SLURM_JOB_ID}.out $final_OUTPUT_DIR/sub-${PARTICIPANT_LABEL}/



