#!/bin/bash
module load FreeSurfer/7.1.1-centos8_x86_64

SUBJECTS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/ADC/derivatives/freesurfer-v7.1.1 # directory with the output of freesurfer
SUBREGEXP=sub #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
	mkdir $SUBJECTS_DIR/summary_stats; 
fi

echo "SubjID,LLatVent,RLatVent,Lthal,Rthal,Lcaud,Rcaud,Lput,Rput,Lpal,Rpal,Lhippo,Rhippo,Lamyg,Ramyg,Laccumb,Raccumb,ICV" > ${SUBJECTS_DIR}/summary_stats/aseg_volume_table.csv

for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
	printf "Extracting from $subj_id...\r"
	subj_name=`basename $subj_id`
	printf "%s,"  "${subj_name}" >> ${SUBJECTS_DIR}/summary_stats/aseg_volume_table.csv

	for x in Left-Lateral-Ventricle Right-Lateral-Ventricle Left-Thalamus Right-Thalamus Left-Caudate Right-Caudate Left-Putamen Right-Putamen Left-Pallidum Right-Pallidum Left-Hippocampus Right-Hippocampus Left-Amygdala Right-Amygdala Left-Accumbens-area Right-Accumbens-area; do
		printf "%g," `grep  ${x} ${subj_id}/stats/aseg.stats | awk '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/aseg_volume_table.csv
	done
	printf "%g" `cat ${subj_id}/stats/aseg.stats | grep IntraCranialVol | awk -F, '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/aseg_volume_table.csv
	echo "" >> ${SUBJECTS_DIR}/summary_stats/aseg_volume_table.csv
done

