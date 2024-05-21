#!/bin/bash
#SBATCH --job-name=qsiprep
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=40G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-00:0:0
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

module load foss/2020a
module load ANTs/2.4.1
module load MRtrix/3.0.3-Python-3.8.2
module load fsl/6.0.5.1



### SETTINGS ##
#QSIPREP=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.16.1.sif
QSIPREP=/home/llorenzini/qsiprep-0.19.1.sif
BIDS_DIR=$1
OUTPUT_DIR=$2
PARTICIPANT_LABEL=$3 # participant label (without 'sub-')
WORK_DIR=$4 #working directory
FS_LICENSE=/home/radv/llorenzini/license.txt
final_OUTPUT_DIR=$5
session=$6
RECON_SPEC=$7
RUN_DIR=$8

# create output directory if needed
if [ ! -d $OUTPUT_DIR ]; then
	mkdir -p $OUTPUT_DIR
	mkdir -p $OUTPUT_DIR/qsiprep
	mkdir -p $OUTPUT_DIR/qsirecon
else
	printf "output directory already exists\n\n"
fi


# create working directory if needed
if [ ! -d $WORK_DIR ]; then
	mkdir -p $WORK_DIR
else
	printf "working directory already exists\n\n"
fi




# run qsiprep if not previously done   
if [ -f "${final_OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL}/$session/dwi/sub-${PARTICIPANT_LABEL}_${session}_space-T1w_desc-preproc_dwi.nii.gz" ]; then

	printf "qsiprep already done for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"
	

	# copy for further processing
#	cp -r ${final_OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL} $OUTPUT_DIR/qsiprep/;
#	cp -r ${final_OUTPUT_DIR}/qsirecon/sub-${PARTICIPANT_LABEL} $OUTPUT_DIR/qsirecon/;




else	
	rm -rf ${WORK_DIR}/* # empty working directory (avoids overlaps with previous executions)	
	cp $FS_LICENSE $WORK_DIR		
	printf "starting qsiprep for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"	
	
	singularity run --cleanenv -B $BIDS_DIR -B $OUTPUT_DIR -B $WORK_DIR -B `dirname $RECON_SPEC` -B `dirname $FS_LICENSE` $QSIPREP $BIDS_DIR $OUTPUT_DIR participant \
	--participant-label $PARTICIPANT_LABEL \
	--output-space {T1w,template} \
	--template MNI152NLin2009cAsym \
	--output-resolution 2 \
	--hmc_model eddy \
	--dwi-only \
	--recon-spec $RECON_SPEC \
	--fs-license-file $FS_LICENSE \
	--work-dir ${WORK_DIR} \
	--verbose \
	--verbose
fi



if [[ -d ${OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL} ]]; then 
rsync -avu --progress --ignore-existing ${OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL} $final_OUTPUT_DIR/qsiprep/
rsync -avu --progress --ignore-existing ${OUTPUT_DIR}/qsirecon/sub-${PARTICIPANT_LABEL} $final_OUTPUT_DIR/qsirecon/
fi 

if [[ -f ${OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL}.html ]]; then

cp -rf ${OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL}.html $final_OUTPUT_DIR/qsiprep/;

fi

if [[ -f ${OUTPUT_DIR}/qsirecon/sub-${PARTICIPANT_LABEL}.html ]]; then

cp -rf ${OUTPUT_DIR}/qsirecon/sub-${PARTICIPANT_LABEL}.html $final_OUTPUT_DIR/qsirecon/;

fi


rm -rf ${WORK_DIR}
rm -rf ${OUTPUT_DIR}/qsiprep/sub-${PARTICIPANT_LABEL}*
rm -rf ${OUTPUT_DIR}/qsirecon/sub-${PARTICIPANT_LABEL}*
rm -rf ${BIDS_DIR}/sub-${PARTICIPANT_LABEL}

cd $RUN_DIR
mv slurm-${SLURM_JOB_ID}.out $final_OUTPUT_DIR/qsiprep/sub-${PARTICIPANT_LABEL}/$session
