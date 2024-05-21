SUBJECTS_DIR=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer # directory with the output of freesurfer
SUBREGEXP=ses  #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
mkdir $SUBJECTS_DIR/summary_stats; 
fi

# remove previous extractions
rm -rf ${SUBJECTS_DIR}/summary_stats/apart_rh_gwc.csv ${SUBJECTS_DIR}/summary_stats/apart_lh_gwc.csv

echo "SubjID,bankssts,caudalanteriorcingulate,caudalmiddlefrontal,cuneus,entorhinal,fusiform,inferiorparietal,inferiortemporal,isthmuscingulate,lateraloccipital,lateralorbitofrontal,lingual,medialorbitofrontal,middletemporal,parahippocampal,paracentral,parsopercularis,parsorbitalis,parstriangularis,pericalcarine,postcentral,posteriorcingulate,precentral,precuneus,rostralanteriorcingulate,rostralmiddlefrontal,superiorfrontal,superiorparietal,superiortemporal,supramarginal,frontalpole,temporalpole,transversetemporal,insula" > ${SUBJECTS_DIR}/summary_stats/apart_rh_gwc.csv
echo "SubjID,bankssts,caudalanteriorcingulate,caudalmiddlefrontal,cuneus,entorhinal,fusiform,inferiorparietal,inferiortemporal,isthmuscingulate,lateraloccipital,lateralorbitofrontal,lingual,medialorbitofrontal,middletemporal,parahippocampal,paracentral,parsopercularis,parsorbitalis,parstriangularis,pericalcarine,postcentral,posteriorcingulate,precentral,precuneus,rostralanteriorcingulate,rostralmiddlefrontal,superiorfrontal,superiorparietal,superiortemporal,supramarginal,frontalpole,temporalpole,transversetemporal,insula" > ${SUBJECTS_DIR}/summary_stats/apart_lh_gwc.csv
for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
	subj_name=`basename $subj_id`
	printf "extracting GWC from $subj_name...\n"
	printf "%s,"  "${subj_name}" >> ${SUBJECTS_DIR}/summary_stats/apart_rh_gwc.csv
	printf "%s,"  "${subj_name}" >> ${SUBJECTS_DIR}/summary_stats/apart_lh_gwc.csv
	for x in bankssts caudalanteriorcingulate caudalmiddlefrontal cuneus entorhinal fusiform inferiorparietal inferiortemporal isthmuscingulate lateraloccipital lateralorbitofrontal lingual medialorbitofrontal middletemporal parahippocampal paracentral parsopercularis parsorbitalis parstriangularis pericalcarine postcentral posteriorcingulate precentral precuneus rostralanteriorcingulate rostralmiddlefrontal superiorfrontal superiorparietal superiortemporal supramarginal frontalpole temporalpole transversetemporal insula; do
		printf "%g," `grep  ${x} ${subj_id}/stats/rh.w-g.pct.aparc.smoothed.stats | awk '{print $6}' | head -1` >> ${SUBJECTS_DIR}/summary_stats/apart_rh_gwc.csv
		printf "%g," `grep  ${x} ${subj_id}/stats/lh.w-g.pct.aparc.smoothed.stats | awk '{print $6}' | head -1` >> ${SUBJECTS_DIR}/summary_stats/apart_lh_gwc.csv
	done
	echo "" >> ${SUBJECTS_DIR}/summary_stats/apart_rh_gwc.csv
	echo "" >> ${SUBJECTS_DIR}/summary_stats/apart_lh_gwc.csv
done

printf "Script finished!\n\n"
