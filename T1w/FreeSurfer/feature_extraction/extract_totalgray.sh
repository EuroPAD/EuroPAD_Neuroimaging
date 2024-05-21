SUBJECTS_DIR=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/FreeSurfer_crossectional # directory with the output of freesurfer
SUBREGEXP=EPAD  #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
mkdir $SUBJECTS_DIR/summary_stats; 
fi

echo "SubjID, totalGray" > ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv
for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
printf "%s,"  "${subj_id}" >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv
printf "%g" `cat ${subj_id}/stats/aseg.stats | grep TotalGray | awk -F, '{print $4}'` >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv;
echo "" >> ${SUBJECTS_DIR}/summary_stats/totalgraymatter.csv;
done
