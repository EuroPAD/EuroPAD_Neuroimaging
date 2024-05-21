SUBJECTS_DIR=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/FreeSurfer_crossectional # directory with the output of freesurfer
SUBREGEXP=EPAD  #Subject regular expression  # ses to avoid take the template
metric=volume # metric to be extracted, options are from aparcstats2table [area volume thickness thicknessstd meancurv gauscurv foldind curvind]
atlas=Schaefer2018_100Parcels_7Networks_order #aparc # parcellation to be used, must be found in subject folder as [lh].$atlas.stats ## check mri_surf2surf to create new atlases 


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


aparcstats2table --subjects $(cat  subjects_with_parc.txt) --hemi lh --meas $metric --parc=$atlas --tablefile $SUBJECTS_DIR/summary_stats/${atlas}_lh_${metric}_table.txt
aparcstats2table --subjects $(cat subjects_with_parc.txt ) --hemi rh --meas $metric --parc=$atlas --tablefile $SUBJECTS_DIR/summary_stats/${atlas}_rh_${metric}_table.txt


