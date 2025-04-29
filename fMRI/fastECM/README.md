# FastECM Pipeline scripts for the EuroPAD cohort
This pipeline performs**voxel-wise** and **atlas-based fast Eigenvector Centrality Mapping (fastECM)** on resting-state fMRI data.

---

## Overview of Workflow
The fastECM workflow consists of four major stages:

1. **Spatial normalization to MNI152 space**
2. **Creation of subject-wise and group-level gray matter (GM) masks**
3. **Computation of voxel-wise and atlas-based fastECM**
4. **Extraction and export of metrics for further analysis**

---

## Key pre-processing step
Check if all input images/atlases to be used are in a common space (Neurological/Radiological)

### Step 1: Apply MNI152NLin6Asym transformation to subject-specific GM masks using ANTs tools.
**Script:** `a_MNI_transform.sh`  
**Dependencies:** `fsl`, `ANTs`
**FSL MNI152NLin6ASym space used**: mni/tpl-MNI152NLin6Asym_res-02_T1w.nii.gz (in Neurological space) - change accordingly

```bash
bash a_MNI_transform.sh
```

**Inputs:**
- Subject-level GM masks

**Outputs:**
- Transformed GM masks in subject/session folders
- `MNI_gm_mask_paths.txt` — List of all transformed GM masks

---

### Step 2: Create subject-specific thresholded GM masks and a group-level GM mask.
**Script:** `b_GM_masks.sh`  
**Dependencies:** `fslmaths`, `fslmerge`, `fslmaths -Tmin`

```bash
bash b_GM_masks.sh
```

**Outputs:**
- Thresholded, binarized subject-specific GM masks (0.2)
- Group-level mask: `masks/groupmask_label-GM_probseg_MNI152NLin6Asym_0.2_thr_bin.nii.gz`

---

## Step 3: Run fastECM (voxel-wise + atlas-based)

**Script:** `c_run_fastECM.sh`  
**Dependencies:** `MATLAB`, `fastECM` toolbox (in `bias/`)

```bash
bash c_run_fastECM.sh
```

**Inputs:**
- Preprocessed fMRI image
- Atlas: `atlases/Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm_LR.nii.gz`

**Outputs:**
- `voxelwise/` — Voxel-level fastECM maps
- `atlas/` — Atlas-based ECM values (MATLAB `.mat` files)

---

## Step 4: Extract Regional Metrics

**Script:** `d_extract_metrics.R`  
**Dependencies:** `R`, `R.matlab`, `dplyr`

```R
Rscript d_extract_metrics.R
```

**Description:**
- Reads atlas-based `.mat` files listed in `list_fastECMstats.txt`
- Extracts 8 metrics per subject/session
- Outputs subject-wise CSVs named `fastECMstats_<metric>.csv`

---

## Folder Structure

- `bias/` → Contains the **fastECM** MATLAB implementation.
- `mni/` → Stores the **template** image: `tpl-MNI152NLin6Asym_res-02_T1w.nii.gz` in **Neurological** space.
- `masks/` → Stores the **group-level GM mask** and optionally cached subject masks.
- `old_scripts/` → Legacy materials including `run_fastECM.sh`, `EPAD_mask.nii.gz`, etc. (not required for updated runs).

## Atlas Compatibility

You may modify the atlas path in `c_run_fastECM.sh` and `d_extract_metrics.R` if using a different parcellation.

---

## Requirements

- FSL
- ANTs
- MATLAB
- R (with `R.matlab`, `dplyr`)
- `fastECM` toolbox (https://github.com/brain-modelling-group/fastECM)

---

## Maintainer
**Prithvi Arunachalam**  
PhD Candidate, Amsterdam UMC
p.arunachalam@amsterdamumc.nl

Last Updated: 22-04-2025
