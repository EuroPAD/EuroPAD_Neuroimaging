#!/bin/bash
module load FreeSurfer/7.1.1-centos8_x86_64

SUBJECTS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1 # directory with the output of freesurfer
SUBREGEXP=sub #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
mkdir $SUBJECTS_DIR/summary_stats; 
fi

echo "SubjID, totalGray" > ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv

for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
	printf "Extracting from $subj_id...\r"
	printf "%s,"  "${subj_id}" >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv
	printf "%g" `cat ${subj_id}/stats/aseg.stats | grep TotalGray | awk -F, '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv;
	echo "" >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv;
done
