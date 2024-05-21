#!/bin/bash
#SBATCH --job-name=ANTsRgst
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8000              # max memory per node, previousy runs used 5000 to 6000
# Request 4 hours run time, previous runs took around 2 hours
#SBATCH -t 4:0:0
#SBATCH --nice=100			# be nice
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h

## modules 
module load ANTs

# define variables (change according to the system) TODO
moving=$1
fixed=$2
bidsname=$3
session=$4
studydir=$5
output=$6
WORK_DIR=$7


# running antsRegistration
if [ -f "${output}/SPECIFYTRANSFORMNAME" ]; then
	printf "antsregistration already done for subject $bidsname, session $session...\n"

else
	rm -rf ${WORK_DIR}/* # empty working directory (avoids overlaps with previous executions)

	antsRegistration --dimensionality 3 --float 0 --output [${bidsname}_${session}_MNI-to-Subject] \
	--interpolation BSpline \
	--winsorize-image-intensities [0.005,0.995] \
	--use-histogram-matching 0 \
	--initial-moving-transform [$fixed,$moving,1] \
	--transform Rigid[0.1] \
	--metric MI[$fixed,$moving,1,32,Regular,0.25] \
	--convergence [1000x500x250x100,1e-6,10] \
	--shrink-factors 8x4x2x1 \
	--smoothing-sigmas 3x2x1x0vox \
	--transform Affine[0.1] \
	--metric MI[$fixed,$moving,1,32,Regular,0.25] \
	--convergence [1000x500x250x100,1e-6,10] \
	--shrink-factors 8x4x2x1 \
	--smoothing-sigmas 3x2x1x0vox \
	--transform SyN[0.1,3,0] \
	--metric CC[$fixed,$moving,1,4] \
	--convergence [100x70x50x20,1e-6,10] \
	--shrink-factors 8x4x2x1 \
	--smoothing-sigmas 3x2x1x0vox

fi

if [ ! -d $output/${bidsname} ]; then mkdir $output/${bidsname}; fi

# moving output to derivatives
#mv ${bidsname}_${session}_MNI-to-Subject0GenericAffine.mat $output/${bidsname} #TODO
#mv ${bidsname}_${session}_MNI-to-Subject1InverseWarp.nii.gz $output/${bidsname}
#mv ${bidsname}_${session}_MNI-to-Subject1Warp.nii.gz $output/${bidsname}

rm -rf ${WORK_DIR} # make work directory slot available for next run
#rm -rf $output/$bidsname* # clear previous output
#rm -rf $processing/raw/$bidsname # clear scratch/raw

#mv slurm-${SLURM_JOB_ID}.out $output/$bidsname



