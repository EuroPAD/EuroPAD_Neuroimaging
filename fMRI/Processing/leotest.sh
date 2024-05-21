#Testing fmriprep on single subjects


# cohort specific settings (to be changed)
studydir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/AMYPAD/ALFA
processing_BIDS_DIR=/home/radv/lpieperhoff/my-scratch/processing/ALFA/raw/
OUTPUT_DIR=/home/radv/lpieperhoff/my-scratch/processing/ALFA/derivatives/fmriprep/
orig_WORK_DIR=/home/radv/lpieperhoff/my-scratch/processing/ALFA/logs/

SCRIPTS_DIR=$studydir/../scripts/multimodal_MRI_processing/fMRI
RUN_DIR=$studydir/../scripts/multimodal_MRI_processing/fMRI/Processing
ORIG_BIDS_DIR=$studydir/raw
final_OUTPUT_DIR=$studydir/derivatives/fmriprep
ATLAS_FILE=$studydir/../scripts/multimodal_MRI_processing/atlases/schaeffer_100.nii.gz
#ATLAS_FILE=$studydir/scripts/fMRI/BN_Atlas_246_2mm.nii.gz
session=$1 # which session to be processed?

# create final output directory if needed
if [ ! -d $final_OUTPUT_DIR ]; then
	mkdir -p $final_OUTPUT_DIR
else
	printf "final output directory already exists...\n\n"
fi

# copy dataset description if needed
if [ -f $processing_BIDS_DIR/dataset_description.json ]; then
	printf "Dataset description already copied...\n\n"
else
	cp $ORIG_BIDS_DIR/dataset_description.json $processing_BIDS_DIR/dataset_description.json
	printf "Dataset description copied...\n\n"
fi

n=1 #only running for first participant
for subjectname in `ls -d ${ORIG_BIDS_DIR}/sub-*`; do
	if [ $n == 1 ]; then

	bidsname="`basename $subjectname`"; 
	PARTICIPANT_LABEL="`echo $bidsname | cut -d '-' -f 2`"
	WORK_DIR=${orig_WORK_DIR}$PARTICIPANT_LABEL	

	echo "Processing subject $PARTICIPANT_LABEL..."

	mkdir $WORK_DIR;
	cd $RUN_DIR 

	mkdir $processing_BIDS_DIR/$bidsname
	cp -rf $subjectname/$session $processing_BIDS_DIR/$bidsname
	printf "Participant files copied to scratch...\n\n"

	#from here is normally the processing_slurm_cross.sh call
#sbatch $SCRIPTS_DIR/fmri_processing_slurm_cross.sh $processing_BIDS_DIR $OUTPUT_DIR $PARTICIPANT_LABEL $WORK_DIR $final_OUTPUT_DIR $ATLAS_FILE $session
rundir=${PWD}  # directory from where it is run  (and the log is created)))
FMRIPREP=/opt/aumc-containers/singularity/fmriprep/fmriprep-21.0.1.sif # fmriprep singularity file
BIDS_DIR=$processing_BIDS_DIR
FS_LICENSE=$FREESURFER_HOME/license.txt
DENOISE=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/AMYPAD/ALFA/scripts/multimodal_MRI_processing/fMRI/Processing/denoise-ICAAROMA_FC_LL.py
ses=$session


# read atlas
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

if [ -f "${final_OUTPUT_DIR}/sub-${PARTICIPANT_LABEL}/ses-01/func/sub-${PARTICIPANT_LABEL}_ses-01_task-rest_space-T1w_desc-preproc_bold.nii.gz" ]; then

	
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

	else 
		printf "Not processing $subjectname\n\n"
	
	fi

	n=$n #+1

done



echo "Script finished!"
