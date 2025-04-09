To obtain fixel metrics follow these steps

1)make_fixels_main_script.sh is the first one to run (you have to split it in smaller scripts to slurm it. In old there are already some scripts that I used)

2)make_design_matrix.R to create the contrast and design matrix files

3)make_analysis_whole_brain.sh is the last one,modify it according to your contrast



If you want to obtain fixel metrics at the tract level

1)make_fixels_main_script.sh 

2)make_tract_masks_tractseg.sh

3)make_design_matrix.R

4a)If you want the mean across tracts use extract_tracts_fixels_average.sh 

4b)otherwise use call_make_analysis_tractwise.sh and make_analysis_tractwise.sh to run the analysis at the fixel level tractwise and then extract the mean across the significantly different fixels
