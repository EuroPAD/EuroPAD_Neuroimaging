#!/bin/bash

basedir=/home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
rawdir=$basedir/rawdata
file_EchoTime=$basedir/code/multimodal_MRI_processing/T1w/EchoTime.csv

echo sub,ses,mri_EchoTime > $file_EchoTime

for sub in `ls -d $rawdir/sub-*`; do
	subject=$(basename $sub)
	
	for ses in `ls -d $sub/ses-*`; do
	session=$(basename $ses)
	json="$ses/anat/*T1w.json"
	
	if [ -f $json ]; then
		TE=$(cat $json | jq '.EchoTime')
	else
		TE=NA
	fi
	echo $subject,$session,$TE >> $file_EchoTime
	done
done
