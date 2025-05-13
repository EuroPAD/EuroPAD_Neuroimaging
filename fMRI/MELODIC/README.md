
# MELODIC

These scripts perform and evaluate **group-level spatial independent component analysis** on resting-state fMRI data.

---

## Overview of Workflow

There are four scripts:

1. a_melodic: runs MELODIC in FSL on a full dataset of preprocessed rs-fMRI files
2. b_fslcc: generates spatial cross correlations between the MELODIC components and a specified atlas file
3. c_heatmap: generates spatial correlation heatmaps on the basis of the *.csv file generated in step 2 [b_fslcc]
4. d_generate_MELODIC_figure: generates upscaled images of all MELODIC components and saves figures of the upscaled components overlayed on the MNI T1 template

## Maintainer

**Leonard Pieperhoff**  
PhD Candidate, Amsterdam UMC
l.pieperhoff@amsterdamumc.nl

Last Updated: 2025-05-01
