#!/bin/bash

basedir=/home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
rawdir=$basedir/rawdata
file_JsonParameters=$basedir/code/EuroPAD_JSON_Parameters_$(date +"%Y_%m_%d").csv

echo sub,ses,Manufacturer,FieldStrength,ConversionSoftwareVersion > $file_JsonParameters

for sub in `ls -d $rawdir/sub-*`; do
	subject=$(basename $sub)
	
	for ses in `ls -d $sub/ses-*`; do
	session=$(basename $ses)
	json=$(ls -d $ses/*/*.json | head -1)
	
	if [ -f $json ]; then
		manufacturer=$(cat $json | jq '.Manufacturer')
		fieldstrength=$(cat $json | jq '.MagneticFieldStrength')
		dcm2niixversion=$(cat $json | jq '.ConversionSoftwareVersion')
	else
		manufacturer=NA
		fieldstrength=NA
		dcm2niixversion=NA
	fi
	echo $subject,$session,$manufacturer,$fieldstrength,$dcm2niixversion >> $file_JsonParameters
	done
done

