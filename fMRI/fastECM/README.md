# FastECM Pipeline
Repository for storing chunk of codes to run fastECM

# Updated FastECM Pipeline scripts for the EuroPAD cohort
This pipeline is designed to perform voxel-wise and atlas-based fastECM (fast Eigenvector Centrality Mapping) analysis on resting-state fMRI data, specifically focusing on applying transformations, creating group-level gray matter (GM) masks, and running the fastECM algorithm on both voxel-wise and atlas-level scales.

# Key pre-processing step
Check if all input images are in a common space (Neurological/Radiological)

# Step 1: Apply MNI152NLin6Asym transformation to subject-specific GM masks using ANTs tools.
Script: a_MNI_transform.sh
Key Modules: fsl, ANTs
FSL MNI152NLin6ASym space used: mni/tpl-MNI152NLin6Asym_res-02_T1w.nii.gz (in Neurological space)

Description: The script applies a transformation to align individual gray matter masks into MNI space for multiple subjects and sessions. If the GM mask is not already transformed, the script applies the transformation and logs the result into a mask list file for future use.

Outputs: Transformed GM masks in MNI152NLin6Asym space, stored in individual subject folders, and a compiled list of mask paths (MNI_gm_mask_paths.txt).

# Step 2: Create subject-specific thresholded GM masks and a group-level GM mask.
Script: b_GM_masks.sh
Key Modules: fsl

Description: For each subject and session, this script thresholds GM masks (probability threshold 0.2), binarizes them, and saves them in the subject's directory. Once all subject-specific GM masks are generated, a group mask is created using FSL tools, which is required for subsequent analysis.

Outputs:
Individual subject GM masks: Stored in the anatomical folder of each session.
Group GM mask: masks/groupmask_label-GM_probseg_MNI152NLin6Asym_0.2_thr_bin.nii.gz created in the masks directory.

# Step 3: Perform voxel-wise and atlas-based fastECM for each subject and session.
Script: c_run_fastECM.sh
Key Modules: matlab, bias folder with fastECM (from GitHub)
Atlas used: atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR.nii.gz (atlas in neurological space for consistency)

Description:The script performs the fastECM analysis for resting-state fMRI data. For each subject and session, it checks for the availability of a preprocessed fMRI BOLD image. If available, it computes both voxel-wise and atlas-based fastECM results using the fastECM MATLAB script. The voxel-wise results are calculated using the group GM mask, and atlas-based results use the Schaefer2018 atlas.

Outputs:
Voxel-wise fastECM results: Saved in the voxelwise directory of each session.
Atlas-based fastECM results: Saved in the atlas directory of each session.


# Old script folder
run_fastECM.sh
EPAD_mask.nii.gz
EPAD_mask_2mm.nii.gz

