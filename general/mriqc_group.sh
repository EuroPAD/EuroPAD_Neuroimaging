#!/bin/bash
#SBATCH --job-name=mriqc
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time 12:00:00
#SBATCH --mem=16G
#SBATCH --partition=luna-long





# Group-level run of MRIQC on already computed subject-level data

# variables

mriqc=/opt/aumc-containers/singularity/mriqc/mriqc-24.0.0.sif
BIDS=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
rawdata=${BIDS}/rawdata
rawdatatmp=/scratch/radv/lpieperhoff/rawdata
derivatives=${BIDS}/derivatives/mriqc-v24.0.0
derivativestmp=/scratch/radv/lpieperhoff/mriqc-v24.0.0

mkdir -p $rawdatatmp
cp --no-clobber $rawdata/participants.tsv $rawdatatmp/
cp --no-clobber $rawdata/dataset_description.json $rawdatatmp/
cp --no-clobber -r $rawdata/sub-* $rawdatatmp/

mkdir -p $derivativestmp
cp --no-clobber -r $derivatives/sub-* $derivativestmp/
rm $derivativestmp/*html # keep only the directories with .json files

# clean wrong subs from derivatives
for sub in `ls -d $derivativestmp/sub-*`; do
subject=$(basename $sub);

if [[ ! -d $rawdata/$subject ]]; then
rm -rf $sub;
fi
done


# MRIQC call
singularity run --cleanenv $mriqc ${rawdata}/ ${derivativestmp}/ group --work-dir /scratch/radv/lpieperhoff/mriqc --no-sub; 

# --cleanenv -B $BIDS -B $HOME

ls $derivativestmp
