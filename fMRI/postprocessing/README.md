# Post-processing: Functional Connectome and Graph Properties

This directory contains post-processing pipelines to generate functional brain connectomes and compute graph-theoretical measures from preprocessed fMRI data. It consists of two main modules:

---

## `compute_connectome/`

### Overview
This module extracts region-wise BOLD time series using a provided atlas and computes pairwise functional connectivity (FC) matrices. It includes multiple optional/custom preprocessing steps and can produce both the regional time series and connectivity matrices.

### Contents
- `compute_timeseries_connectome.py`: Python script to extract regional time series and generate FC matrices.
- `run_compute_timeseries_connectome.sh`: SLURM job array submission script to process multiple subjects efficiently, with optional post-processed BOLD output and BIDS-style sidecar .json file support.

### Supported Preprocessing Steps
- Drop initial non-steady-state volumes
- Spatial smoothing
- Confound regression (e.g., motion, WM, CSF)
- Detrending
- Band-pass filtering (default: 0.01–0.1 Hz)
- Optional export of the preprocessed BOLD file (.nii.gz)
- BIDS-style JSON sidecar for postprocessed BOLD output

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
  --high_pass 0.01 \
  --save_processed_bold
```

### Outputs (per subject/session)
- Post-processed BOLD image (`*_bold.nii.gz`)
- JSON metadata sidecar (`*_bold.json`)
- Extracted time series (`*_timeseries.csv`)
- Functional connectivity matrix (`*_connectome.csv`)
- Fisher z-transformed matrix and matrix plot (optional)

---

## `compute_graph_properties/`

### Overview
Computes global and regional graph metrics from connectome CSVs. Supports functional, structural, and MIND-based connectomes. Generates individual and group-level outputs.

### Contents
- `compute_graph_properties.py`: Script to calculate global and nodal metrics from FC matrices.
- `run_graph_properties.sh`: SLURM batch submission.

### Output (per subject/session)
- Global metrics CSV
- Regional nodal metrics CSVs (e.g., strength, clustering, betweenness)
- Shortest path matrix
- Communicability matrix
- Diagnostic figures (e.g., matrix plots, histograms)

### SLURM Template
```bash
python compute_graph_properties.py \
  --connectome_type functional_connectome \
  --pipeline_type fmriprep-v23.0.1 \
  --atlas_name Schaefer100 \
  --base_dir /path/to/project \
  --threshold 0.2 \
  --atlas_dir /path/to/atlas \
  --atlas_labels_file /path/to/atlas_labels.csv \
  --input_csv_list /path/to/connectome_file_list.txt \
  --results_folder /path/to/output/results
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
This pipeline has been validated using the **Schaefer2018 100Parcels 17Networks** atlas in MNI152 space, but can also be expanded to other parcellations. Ensure input BOLD data is aligned accordingly.

---

## Citation
If using this pipeline, please cite the EuroPAD project and relevant toolboxes (Nilearn, BCTpy, NetworkX) and atlases (e.g., Schaefer et al., 2018).

---

## Maintainer
**Prithvi Arunachalam**  
PhD Candidate, Amsterdam UMC
p.arunachalam@amsterdamumc.nl

Last Updated: 14-04-2025