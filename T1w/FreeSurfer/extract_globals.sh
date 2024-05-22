#!/bin/bash
# Script to extract global metrics from freesurfer
# No BASH Dependencies

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=$(realpath $(echo $codedir/../../..)) # location of BIDS directory

SUBJECTS_DIR=$studydir/derivatives/freesurfer-v7.1.1 # directory with the output of freesurfer
SUBREGEXP=sub  #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
	mkdir $SUBJECTS_DIR/summary_stats; 
fi

echo "SubjID, BrainSeg, TotalGray" > ${SUBJECTS_DIR}/summary_stats/totalmetrics.csv
for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
	printf "Extracting from $subj_id...\n"
	printf "%s,"  "${subj_id}" >> ${SUBJECTS_DIR}/summary_stats/totalmetrics.csv
	printf "%g," `cat ${subj_id}/stats/aseg.stats | grep BrainSeg, | awk -F, '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/totalmetrics.csv;
	printf "%g" `cat ${subj_id}/stats/aseg.stats | grep TotalGray | awk -F, '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/totalmetrics.csv;
	echo "" >> ${SUBJECTS_DIR}/summary_stats/totalmetrics.csv;
done

printf "Script finished!\n\n"
