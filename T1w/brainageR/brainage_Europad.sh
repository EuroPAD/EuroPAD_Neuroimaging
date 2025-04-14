#!/bin/bash

# given a list of inputs, this script prepare and call the do_one_brainage.sh script to run the brainageR function

## Setting stage
export PATH="/home/radv/scaneva/my-scratch/brainageR/software:$PATH"
BIDSdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
derivativesdir=$BIDSdir/derivatives/brainageR-v2.1
processingdir=/home/radv/$(whoami)/my-scratch/brainageEuropad/EuroPAD_T1s
codedir=$BIDSdir/code/multimodal_MRI_processing/T1w/brainageR

module load matlab
module load fsl
module load R

# create derivatives directory 
mkdir -p $derivativesdir

# make log directory
mkdir -p $processingdir/logs

# Create file list 
#ls $BIDSdir/rawdata/sub*/ses*/anat/*T1w*.nii* > $processingdir/file_list.txt # already created


# START FORLOOPPONE
for i in `cat $codedir/file_list.txt`; do 
	subjfile=`basename $i`
	if [[ -f $derivativesdir/${subjfile//.nii.gz/.csv} ]]; then
		continue;
	fi

	#touch $processingdir/logs/${subjfile//.nii.gz/_log.txt} # create log file

	echo "working on $subjfile"

	cp $i $processingdir/;

	gunzip -f $processingdir/$subjfile;

	subjefilenogz=${subjfile//.gz/}

	sbatch do_one_brainage.sh $subjefilenogz $derivativesdir $processingdir

	while [[ $(squeue -u scaneva | wc -l) -gt 10 ]]; do
		sleep 10; # check every 10 seconds
	done


done  

