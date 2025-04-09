#!/bin/bash
module load FreeSurfer/7.1.1-centos8_x86_64

SUBJECTS_DIR=/home/radv/lpieperhoff/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/freesurfer-v7.1.1 # directory with the output of freesurfer
SUBREGEXP=sub  #Subject regular expression  # ses to avoid take the template
metrics=( area volume thickness foldind curvind ) # metric to be extracted, options are from aparcstats2table [area volume thickness thicknessstd meancurv gauscurv foldind curvind]
atlas=aparc #aparc Schaefer2018_100Parcels_7Networks_order etc # parcellation to be used, must be found in subject folder as [lh].$atlas.stats ## check mri_surf2surf to create new atlases 


## Check subjects 
for subj in $(ls -d $SUBJECTS_DIR/*$SUBREGEXP* ); do 

if [[ -f $subj/stats/lh.${atlas}.stats ]]; then 
	echo $subj; 
fi 

done > subjects_with_parc.txt

# make the stats dir if it does not exist
if [[ ! -d $SUBJECTS_DIR/summary_stats ]]; then
mkdir $SUBJECTS_DIR/summary_stats; 
fi

for metric in "${metrics[@]}"; do
echo "extracting $metric..."
# clear previous extractions
rm $SUBJECTS_DIR/summary_stats/${atlas}_lh_${metric}_table.txt
rm $SUBJECTS_DIR/summary_stats/${atlas}_rh_${metric}_table.txt

# extract
aparcstats2table --subjects $(cat subjects_with_parc.txt) --hemi lh --meas $metric --parc=$atlas --tablefile $SUBJECTS_DIR/summary_stats/${atlas}_lh_${metric}_table.txt
aparcstats2table --subjects $(cat subjects_with_parc.txt ) --hemi rh --meas $metric --parc=$atlas --tablefile $SUBJECTS_DIR/summary_stats/${atlas}_rh_${metric}_table.txt

done

echo "Script finished!"
