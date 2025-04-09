#!/bin/bash


## FROM FMRIPREP DIR

#basedir=/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives
#rawdir=$basedir/fmriprep-v23.0.1

#file_JsonParameters=/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_prithvi/FMRI_JSON_Parameters_$(date +"%Y_%m_%d").csv

#echo sub,ses,AcquisitionDuration,RepetitionTime > $file_JsonParameters

#for sub in $(ls -d $rawdir/sub-* | grep -v '\.html$'); do
#	subject=$(basename $sub)
#	
#	for ses in `ls -d $sub/ses-*`; do
#	session=$(basename $ses)

#	# Display current file being processed
#	echo "Processing: Subject = $subject, Session = $session"

#	json=$ses/func/*task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.json
	
#	if [ -f $json ]; then
#		AcquisitionDuration=$(cat $json | jq '.AcquisitionDuration')
#		RepetitionTime=$(cat $json | jq '.RepetitionTime')
#	else
#		AcquisitionDuration=NA
#		RepetitionTime=NA
#	fi
#	echo $subject,$session,$AcquisitionDuration,$RepetitionTime >> $file_JsonParameters
#	done
#done


## FROM RAW DATA
basedir=/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
rawdir=$basedir/rawdata
file_JsonParameters=/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/sfc_prithvi/FMRI_ALL_JSON_Parameters_$(date +"%Y_%m_%d").csv

echo "sub,ses,manufacturer,manufacturersmodelname,fieldstrength,num_head_coil_channels,protocol_name,scanning_sequence,repetition_time,echo_time,flip_angle,imagingfrequency,matrix,slice_thickness,slice_gap,scan_duration" > "$file_JsonParameters"

for sub in `ls -d $rawdir/sub-*`; do
	subject=$(basename $sub)
	
	for ses in `ls -d $sub/ses-*`; do
	session=$(basename $ses)
	
	# Check if the func/ folder exists
        if [ ! -d "$ses/func" ]; then
            echo "Skipping: $subject $session (No func/ directory)"
            continue
        fi

	json=$ses/func/${subject}_${session}_task-rest_bold.json
	
	if [ -f $json ]; then
            manufacturer=$(jq -r '.Manufacturer // "NA"' "$json")
			manufacturersmodelname=$(jq -r '.ManufacturersModelName // "NA"' "$json")
			fieldstrength=$(jq -r '.MagneticFieldStrength // "NA"' "$json")
			num_head_coil_channels=$(jq -r '.ReceiveCoilName // "NA"' "$json")
			protocol_name=$(jq -r '.ProtocolName // "NA"' "$json")
			
			scanning_sequence=$(jq -r '.ScanningSequence // "NA"' "$json")

			repetition_time=$(jq -r '.RepetitionTime // "NA"' "$json")
            echo_time=$(jq -r '.EchoTime // "NA"' "$json")
            flip_angle=$(jq -r '.FlipAngle // "NA"' "$json")
			imagingfrequency=$(jq -r '.ImagingFrequency // "NA"' "$json")
			matrix=$(jq -r '.AcquisitionMatrix // .AcquisitionMatrixPE // "NA"' "$json")
            slice_thickness=$(jq -r '.SliceThickness // "NA"' "$json")
            slice_gap=$(jq -r '.SpacingBetweenSlices // "NA"' "$json")
            scan_duration=$(jq -r '.AcquisitionDuration // "NA"' "$json")

	else
		# Assign "NA" if JSON is missing
            manufacturer="NA"
            manufacturersmodelname="NA"
            fieldstrength="NA"
            num_head_coil_channels="NA"
            protocol_name="NA"
            scanning_sequence="NA"
            repetition_time="NA"
            echo_time="NA"
            flip_angle="NA"
            imagingfrequency="NA"
            matrix="NA"
            slice_thickness="NA"
			slice_gap="NA"
			scan_duration="NA"

	fi

	# Print processing status
    echo "Processing: Subject = $subject, Session = $session"

	# Append results to the CSV file
	echo $subject,$session,$manufacturer,$manufacturersmodelname,$fieldstrength,$num_head_coil_channels,$protocol_name,$scanning_sequence,$repetition_time,$echo_time,$flip_angle,$imagingfrequency,$matrix,$slice_thickness,$slice_gap,$scan_duration >> $file_JsonParameters
	done
done
