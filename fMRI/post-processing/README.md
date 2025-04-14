# Post-processing: Functional Connectome and Graph Properties

This directory contains post-processing pipelines to generate functional brain connectomes and compute graph-theoretical measures from preprocessed fMRI data. It consists of two main modules:

---

## `compute_connectome/`

### Overview
This module extracts region-wise BOLD time series using a provided atlas and computes pairwise functional connectivity (FC) matrices. It includes multiple optional/custom post-processing steps and can produce both the regional time series and connectivity matrices.

### Contents
- `compute_timeseries_connectome.py`: Python script for the optional/custom post-processing to extract regional time series and generate FC matrices.
- `run_compute_timeseries_connectome.sh`: SLURM job array submission script to process multiple subjects efficiently.

### Supported Post-processing Steps
- Drop initial non-steady-state volumes
- Spatial smoothing
- Confound regression (e.g., motion, WM, CSF)
- Detrending
- Band-pass filtering (default: 0.01–0.1 Hz)

### Modes
- `both`: Compute and save both time series and connectome
- `timeseries`: Compute both but save only the time series
- `connectome`: Compute both but save only the connectome and its visualization

### Example usage
```bash
python compute_timeseries_connectome.py \
  --fmri path/to/preproc_bold.nii.gz \
  --atlas path/to/atlas.nii.gz \
  --atlas_name Schaefer100 \
  --output_dir /path/to/output/ \
  --tag desc-preproc_options \
  --mode both \
  --confounds path/to/confounds.tsv \
  --confound_columns trans_x trans_y trans_z rot_x rot_y rot_z white_matter csf \
  --smoothing 4 \
  --drop_volumes 5 \
  --low_pass 0.1 \
  --high_pass 0.01
```

---

## `compute_graph_properties/`

### Overview
This module computes global and regional graph metrics from functional connectomes using NetworkX and BCTpy. It accepts individual `.csv` matrices and outputs a rich set of network features.

### Contents
- `compute_graph_properties.py`: Script to calculate global and nodal metrics from FC matrices.
- `run_graph_properties.sh`: SLURM batch submission

### Output (per subject/session)
- Global metrics CSV
- Regional nodal metrics CSVs (e.g., strength, clustering, betweenness)
- Shortest path matrix
- Communicability matrix
- Diagnostic figures (e.g., matrix plots, histograms)

### Example usage
```bash



```

---

## Requirements
Install the following Python libraries:
- `numpy`
- `pandas`
- `nilearn`
- `matplotlib`
- `seaborn`
- `networkx`
- `bctpy`

---

## Atlas Compatibility
This pipeline has been validated using the **Schaefer2018 100Parcels 17Networks** atlas in MNI152 space, but can be expanded to other parcellation schemes. Ensure input BOLD data is aligned accordingly.

---

## Citation
If using this pipeline, please cite the EuroPAD project and relevant toolboxes (Nilearn, BCTpy, NetworkX) and atlases (e.g., Schaefer et al., 2018).

---

## Maintainer
**Prithvi Arunachalam**  
PhD Candidate, Amsterdam UMC

Last updated: 14-04-2025

Feel free to contribute or raise issues related to this pipeline!