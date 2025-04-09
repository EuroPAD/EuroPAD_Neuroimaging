#!/bin/bash
# Script to extract Gray-Matter White-Matter tissue contrast after computation
# No BASH dependencies

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/ADC # location of BIDS directory

echo $studydir

SUBJECTS_DIR=$studydir/derivatives/freesurfer-v7.1.1 # directory with the output of freesurfer
SUBREGEXP=ses  #Subject regular expression  # ses to avoid take the template

# make the stats dir if it does not exist
mkdir -p $SUBJECTS_DIR/summary_stats; 

# remove previous extractions
if [[ -f ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv ]]; then
	rm -rf ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv ${SUBJECTS_DIR}/summary_stats/aparc_lh_gwc.csv
fi

echo "SubjID,bankssts,caudalanteriorcingulate,caudalmiddlefrontal,cuneus,entorhinal,fusiform,inferiorparietal,inferiortemporal,isthmuscingulate,lateraloccipital,lateralorbitofrontal,lingual,medialorbitofrontal,middletemporal,parahippocampal,paracentral,parsopercularis,parsorbitalis,parstriangularis,pericalcarine,postcentral,posteriorcingulate,precentral,precuneus,rostralanteriorcingulate,rostralmiddlefrontal,superiorfrontal,superiorparietal,superiortemporal,supramarginal,frontalpole,temporalpole,transversetemporal,insula" > ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv
echo "SubjID,bankssts,caudalanteriorcingulate,caudalmiddlefrontal,cuneus,entorhinal,fusiform,inferiorparietal,inferiortemporal,isthmuscingulate,lateraloccipital,lateralorbitofrontal,lingual,medialorbitofrontal,middletemporal,parahippocampal,paracentral,parsopercularis,parsorbitalis,parstriangularis,pericalcarine,postcentral,posteriorcingulate,precentral,precuneus,rostralanteriorcingulate,rostralmiddlefrontal,superiorfrontal,superiorparietal,superiortemporal,supramarginal,frontalpole,temporalpole,transversetemporal,insula" > ${SUBJECTS_DIR}/summary_stats/aparc_lh_gwc.csv
for subj_id in $(ls -d ${SUBJECTS_DIR}/*${SUBREGEXP}*); do 
	subj_name=`basename $subj_id`
	printf "extracting GWC from $subj_name...\n"
	printf "%s,"  "${subj_name}" >> ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv
	printf "%s,"  "${subj_name}" >> ${SUBJECTS_DIR}/summary_stats/aparc_lh_gwc.csv
	for x in bankssts caudalanteriorcingulate caudalmiddlefrontal cuneus entorhinal fusiform inferiorparietal inferiortemporal isthmuscingulate lateraloccipital lateralorbitofrontal lingual medialorbitofrontal middletemporal parahippocampal paracentral parsopercularis parsorbitalis parstriangularis pericalcarine postcentral posteriorcingulate precentral precuneus rostralanteriorcingulate rostralmiddlefrontal superiorfrontal superiorparietal superiortemporal supramarginal frontalpole temporalpole transversetemporal insula; do
		printf "%g," `grep  ${x} ${subj_id}/stats/rh.w-g.pct.aparc.smoothed.stats | awk '{print $6}' | head -1` >> ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv
		printf "%g," `grep  ${x} ${subj_id}/stats/lh.w-g.pct.aparc.smoothed.stats | awk '{print $6}' | head -1` >> ${SUBJECTS_DIR}/summary_stats/aparc_lh_gwc.csv
	done
	echo "" >> ${SUBJECTS_DIR}/summary_stats/aparc_rh_gwc.csv
	echo "" >> ${SUBJECTS_DIR}/summary_stats/aparc_lh_gwc.csv
done

printf "Script finished!\n\n"
