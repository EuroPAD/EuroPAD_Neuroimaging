# MIND Network Construction for EuroPAD Cohort

This pipeline generates MIND (Morphometric INverse Diffusion) brain networks from FreeSurfer outputs using the different brain parcellation (Eg: **Schaefer2018_100Parcels_7Networks**) for all subjects in the EuroPAD cohort.

## Overview

The workflow uses the FreeSurfer-reconstructed surfaces and computes regional morphometric similarity based on features like cortical thickness, mean curvature, volume, surface area, and sulcal depth. This is done using three scripts:

1. **`FStoSchaefer2018_100Parcels_7Networks.sh`** – Extracts morphometric features per atlas-specific region.
2. **`MIND-networks_Schaefer2018_100Parcels_7Networks.py`** – Computes the MIND network matrix.
3. **`MIND-networks-Schaefer2018_100Parcels_7Networks_sbatch.sh`** – SLURM batch script to automate the process for the full cohort.

---

## Directory Structure

```bash
/path/to/freesurfer/
├── sub-01/
│   ├── mri/
│   ├── surf/
│   └── ...
├── sub-02/
└── ...
```

---

## Required Features

The following five features are used for MIND computation:
- Cortical Thickness (`CT`)
- Mean Curvature (`MC`)
- Volume (`Vol`)
- Sulcal Depth (`SD`)
- Surface Area (`SA`)

---

## Parcellation

This pipeline uses different parcellation scheme (eg: **Schaefer2018_100Parcels_7Networks_order**). Make sure this atlas is correctly mapped to the FreeSurfer subjects' surfaces before running the pipeline.

---

## Usage Instructions

### 1. Preprocessing with FreeSurfer

Ensure each subject has been processed using FreeSurfer's `recon-all` pipeline.

```bash
recon-all -i <input_T1.nii> -s <subject_id> -all
```

---

### 2. Extract Features (Optional Custom Step)

If needed, adapt and run the script `FStoSchaefer2018_100Parcels_7Networks.sh` to extract surface-based morphometric features.

---

### 3. Compute MIND Network for One Subject

Run the Python script:

```bash
python MIND-networks_Schaefer2018_100Parcels_7Networks.py \
  /absolute/path/to/freesurfer/sub-XX \
  -o /path/to/output/
```

This will save a CSV file:

```
sub-XX_MIND-Schaefer2018_100Parcels_7Networks_order.csv
```

---

### 4. Run on HPC with SLURM for Full Cohort

Use the SLURM batch script to automate MIND matrix computation for all subjects in the EuroPAD cohort:

```bash
sbatch MIND-networks-Schaefer2018_100Parcels_7Networks_sbatch.sh
```

Ensure paths are correctly defined in the SLURM script:
- `FS_SUBJECTS_DIR`
- `OUTPUT_DIR`
- `SBATCH --array` (Maximum 2000 at a time, so run in multiple batches as needed)
- Path to the Python environment (if needed)

---

## Output

Each subject's output will be a CSV file of a symmetric 100x100 matrix, representing the MIND network using the Schaefer parcellation.

---

## Dependencies

- Python ≥ 3.6 
- FreeSurfer ≥ 6.0 
- Required Python modules:
  - `pandas`, `numpy`, `os`, `argparse`
  - MIND computation module from your repository (`MIND.compute_MIND`)

---

## Citation

- Sebenius, I., Seidlitz, J., Warrier, V. et al. Robust Estimation of Cortical Similarity Networks from Brain MRI. Nat Neurosci 26, 1461–1471 (2023). https://doi.org/10.1038/s41593-023-01376-7 
- https://github.com/isebenius/MIND 
