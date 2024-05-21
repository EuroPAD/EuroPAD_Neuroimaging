gedit #!/bin/bash
#SBATCH --job-name=qsiprep
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=40G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-00:0:0
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

module load Anaconda3/2022.05
module load GCC/9.3.0
module load OpenMPI/4.0.3
module load foss/2020a
module load ANTs/2.4.1
module load MRtrix/3.0.3-Python-3.8.2
module load fsl/6.0.5.1

### SETTINGS ##
QSIPREP=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.16.1.sif

$processing_BIDS_DIR=$1
OUTPUT_DIR=$2
PARTICIPANT_LABEL=$3 # participant label (without 'sub-')
WORK_DIR=$4 #working directory
FS_LICENSE=/home/radv/mtranfa/license.txt
final_OUTPUT_DIR=$5
session=$6
RECON_SPEC=$7
RUN_DIR=$8
qsiprep_dir=$9 
freesurfer_dir=${10}

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

# run qsirecon   
rm -rf ${WORK_DIR}/* # empty working directory (avoids overlaps with previous executions)	
cp $FS_LICENSE $WORK_DIR		
printf "starting qsiprep for sub-${PARTICIPANT_LABEL} from ${BIDS_DIR}\n\n"	
	
	singularity run --cleanenv -B $processing_BIDS_DIR -B $OUTPUT_DIR -B $WORK_DIR -B `dirname $RECON_SPEC` -B `dirname $FS_LICENSE` -B $freesurfer_dir $QSIPREP $processing_BIDS_DIR $OUTPUT_DIR participant \
	--skip-bids-validation \
	--participant-label $PARTICIPANT_LABEL \
	--freesurfer-input $freesurfer_dir \
	--output-space {T1w,template} \
	--template MNI152NLin2009cAsym \
	--output-resolution 2 \
	--hmc_model eddy \
	--use-syn-sdc \
	--force-syn \
	--recon-spec $RECON_SPEC \
	--fs-license-file $FS_LICENSE \
	--skip-odf-reports \
	--work-dir ${WORK_DIR} \
	--verbose \
	--verbose
fi
