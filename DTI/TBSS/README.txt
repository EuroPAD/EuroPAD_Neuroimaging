## Tract-Based Spatial Statistics Analysis ##

This folder provides the scripts to run the full pipeline of TBSS, as outlined in the FSL website. 

# 1. tbss_step1.sh : this first script organizes the folders and the data as required, and run the first FSL TBSS command from FSL

# 2. QC : after that, the QC files generated should be visually checked and names of the subject/sessions to exclude should be saved in the QC_excluded.txt file in this folder. 

# 3. tbss_step2.sh :  this script excludes the bad quality images and run the remaining parts of the TBSS pipeline following standard procedures. Specific options can be changed within the script. A "slurm" version is provided for systems that allow for job management (tbss2_slurm and tbss3_slurm). 

# 4. cross_TBSS_extract_values.sh :  this script extracts DTI scalars values for the processed images, both globally and for each region of the JHU WM atlas.

