### This scripts calls the fMRI processing pipeline in 'fMRI_processing_slurm.sh' treating each session separately. 
#it can be run only for specific sessions. E.g. `. call_fmri_processing_cross.sh ses-01` will process all ses-01 in the dataset


# cohort specific settings (to be changed)
studydir=/home/llorenzini/lood_storage/divi/Projects/ExploreASL/Twins/Twins_FU_bids
processing_BIDS_DIR=/scratch/llorenzini/Twins_FU_bids/raw
OUTPUT_DIR=/scratch/llorenzini/Twins_FU_bids/derivatives/fmriprep
orig_WORK_DIR=/scratch/llorenzini/Twins_FU_bids/logs



SCRIPTS_DIR=$studydir/scripts/fMRI
RUN_DIR=$studydir/scripts
ORIG_BIDS_DIR=$studydir/raw
final_OUTPUT_DIR=$studydir/derivatives/fmriprep
ATLAS_FILE=$studydir/scripts/fMRI/schaeffer_100.nii.gz
#ATLAS_FILE=$studydir/scripts/fMRI/BN_Atlas_246_2mm.nii.gz
session=$1 # which session to be processed?


# create final output directory if needed
if [ ! -d $final_OUTPUT_DIR ]; then
	mkdir -p $final_OUTPUT_DIR
else
	printf "final output directory already exists\n\n"
fi

# copy dataset description json

cp $ORIG_BIDS_DIR/dataset_description.json $processing_BIDS_DIR/dataset_description.json

for subjectname in `ls -d ${ORIG_BIDS_DIR}/sub-*`; do

bidsname="`basename $subjectname`"; 
PARTICIPANT_LABEL="`echo $bidsname | cut -d '-' -f 2`"
WORK_DIR=${orig_WORK_DIR}/$PARTICIPANT_LABEL

# Make Subject Working Directory and run fMRI (sleeping 1 minute)
mkdir $WORK_DIR;
sleep 1m
cd $RUN_DIR 

mkdir $processing_BIDS_DIR/$bidsname
cp -rf $subjectname/$session $processing_BIDS_DIR/$bidsname


sbatch $SCRIPTS_DIR/fmri_processing_slurm_cross.sh $processing_BIDS_DIR $OUTPUT_DIR $PARTICIPANT_LABEL $WORK_DIR $final_OUTPUT_DIR $ATLAS_FILE $session

while [[ $(ls $orig_WORK_DIR/ | wc -l) = 10 ]]; do 
sleep 10; 
done



done




