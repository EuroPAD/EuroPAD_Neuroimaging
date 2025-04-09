#!/bin/bash
#SBATCH --job-name=brainage
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G              # max memory per node
# Request 4 hours run time
#SBATCH -t 4:0:0
#SBATCH --nice=100                      # be nice
#SBATCH --partition=luna-short



subjfile=$1
derivativesdir=$2
processingdir=$3

brainageR -f $processingdir/$subjfile -o $processingdir/${subjfile//.nii/.csv};

rm $processingdir/logs/${subjfile//.nii/_log.txt}
mv $processingdir/${subjfile//.nii/.csv} $derivativesdir/
mv $processingdir/${subjfile//.nii/_tissue_volumes.csv} $derivativesdir/
rm -rf $processingdir/$subjfile
rm -rf $processingdir/slicesdir_${subjfile}*
