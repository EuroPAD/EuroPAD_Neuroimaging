### This scripts calls the DTI  processing pipeline in 'dti_processing_slurm.sh' 
# start with longitudinal pipeline for now

# cohort specific settings (to be changed)
studydir=/home/radv/mtranfa/my-rdisk/RNG/Projects/ExploreASL/EPAD
processing_BIDS_DIR=/scratch/radv/mtranfa/EPAD_fs/raw
OUTPUT_DIR=/scratch/radv/mtranfa/EPAD_fs/derivatives
orig_WORK_DIR=/scratch/radv/mtranfa/EPAD_fs/logs
dtishell=single # multi or single

SCRIPTS_DIR=$studydir/scripts/multimodal_MRI_processing/DTI
RUN_DIR=$studydir/scripts/mario
ORIG_BIDS_DIR=$studydir/raw
final_OUTPUT_DIR=$studydir/derivatives
#ATLAS_FILE=$studydir/scripts/multimodal_MRI_processing/atlases/schaeffer_100.nii.gz
#ATLAS_FILE=$studydir/scripts/fMRI/BN_Atlas_246_2mm.nii.gz
session=ses-01 # which session to be processed?


##
if [[ dtishell=="single" ]]; then 

	RECON_SPEC=$SCRIPTS_DIR/mrtrix_singleshell_ss3t_ACT-hsvs.json;
	acq="singleshell"

elif  [[ dtishell=="multi" ]]; then

	RECON_SPEC=$SCRIPTS_DIR/dhollander_msmt_gqi.json; 	
	acq="multishell"

fi


# create final output directory if needed
if [ ! -d $final_OUTPUT_DIR/qsiprep ]; then
	mkdir -p $final_OUTPUT_DIR/qsiprep
	mkdir -p $final_OUTPUT_DIR/qsirecon
else
	printf "final output directory already exists\n\n"
fi

# copy dataset description json

cp $ORIG_BIDS_DIR/dataset_description.json $processing_BIDS_DIR/dataset_description.json


for subjectname in `ls -d ${ORIG_BIDS_DIR}/sub-* | tail -810`; do


bidsname="`basename $subjectname`"; 
PARTICIPANT_LABEL="`echo $bidsname | cut -d '-' -f 2`"
WORK_DIR=${orig_WORK_DIR}/$PARTICIPANT_LABEL
#qsiprep_dir=${final_OUTPUT_DIR}/qsiprep/${bidsname}
#freesurfer_dir=${final_OUTPUT_DIR}/FreeSurfer_crossectional/${bidsname}
qsiprep_dir=${final_OUTPUT_DIR}/qsiprep/
freesurfer_dir=${final_OUTPUT_DIR}/FreeSurfer_longitudinal/

if [[ -d $subjectname/$session/dwi ]]; then 
	# Make Subject Working Directory and run DTI (sleeping 1 minute)
	mkdir $WORK_DIR;
	sleep 1m
	cd $RUN_DIR 

	#nvisit=`ls $subjectname | wc -l`


	mkdir $processing_BIDS_DIR/$bidsname
	cp -rf $subjectname/$session $processing_BIDS_DIR/$bidsname/

	sbatch $SCRIPTS_DIR/dti_recon_with_FreeSurfer_slurm.sh $processing_BIDS_DIR $OUTPUT_DIR $PARTICIPANT_LABEL $WORK_DIR $final_OUTPUT_DIR $session $RECON_SPEC $RUN_DIR $qsiprep_dir $freesurfer_dir;

	
	#cp -rf $subjectname $processing_BIDS_DIR
	#sbatch $SCRIPTS_DIR/dti_processing_slurm.sh $processing_BIDS_DIR $OUTPUT_DIR $PARTICIPANT_LABEL $WORK_DIR $final_OUTPUT_DIR   

fi


while [[ $(ls $orig_WORK_DIR/ | wc -l) = 2 ]]; do 

sleep 10; 
done


done 

