SCRIPTS_DIR=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI/Processing
RUN_DIR=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI
ORIG_BIDS_DIR=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/test/raw #change here
processing_BIDS_DIR=/scratch/radv/llorenzini/EPAD/raw
OUTPUT_DIR=/scratch/radv/llorenzini/EPAD/derivatives/fmriprep
final_OUTPUT_DIR=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/test/derivatives/fmriprep #change here
orig_WORK_DIR=/scratch/radv/llorenzini/EPAD/logs
ATLAS_FILE=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/schaeffer_100.nii.gz
#ATLAS_FILE=/home/llorenzini/lood_storage/divi/Projects/ExploreASL/Twins/Twins_bids/scripts/fMRI/BN_Atlas_246_2mm.nii.gz

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




#cp -rf $subjectname $processing_BIDS_DIR
if [[ `ls -d $subjectname/*/func | wc -l` -gt 0  ]]; then  # only if there is at least one functional folder

# Make Subject Working Directory and sleep
mkdir $WORK_DIR;
sleep 1m
cd $RUN_DIR 

# run
sbatch $SCRIPTS_DIR/fmri_processing_slurm_long.sh $processing_BIDS_DIR $OUTPUT_DIR $PARTICIPANT_LABEL $WORK_DIR $final_OUTPUT_DIR $ATLAS_FILE $subjectname

fi

#while [[ $(ls $orig_WORK_DIR/ | wc -l) = 10 ]]; do 
#sleep 10; 
#done



done




