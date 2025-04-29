## Fixel-Based Analysis ##

This folder provides the scripts to run the full fixel-based analysis pipeline.

# To obtain fixel metrics follow the steps numbered from 01 to 14.


Additionally:

In the fixel_statistics folder you will find example code to run fixel level statistics in selected WM bundles.


In the auxilliary_functions folder you will find :

- scripts to run some of the main steps as arrays and other auxilliary functions

- scripts for QC (make_fod_qc_images.sh; make_mask_qc_images.sh)

- a script to obtain bundle level masks using TractSeg (make_tract_masks_tractseg.sh)

- a script to merge selected WM bundles (create_merged_WM_tck_files.sh)

- scripts to extract bundle level and whole brain average fixel metrics (extract_tract_fixels_average.sh extract_whole_brain_fixels_average.sh)

- a script to assing significant fixels to WM bundles after running fixel statistics at the whole brain level (assign_fixels_to_single_WM_bundles.sh)

- a script to display significant fixels as streamlines (display_results_using_streamlines_for_loop.sh)

- scripts to compute effect size and corrected p-values maps (compute_effect_size_maps.sh and compute_pval_for_5k_permutations.sh)

- a script to perform fixel-to-fixel connectivity and smoothing at the bundle level

- other foldes containing example scripts to run fixel statistics in R using confixel (confixel and Rscripts - see https://github.com/PennLINC/ConFixel for further details)


The longitudinal pipeline folder is under construction.

 
