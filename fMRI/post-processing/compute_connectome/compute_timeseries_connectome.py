#!/usr/bin/env python3
"""
Combined pipeline to extract regional time series and compute functional connectomes.

Supports preprocessing steps:
- Drop initial volumes for steady state (recommended: 4–6)
- Spatial smoothing
- Confound regression (e.g., motion, CSF, WM)
- Detrending
- Band-pass filtering (default: 0.01–0.1 Hz)

Recommended preprocessing order:
1. Drop non-steady-state volumes from both fMRI and confounds
2. Apply confound regression, filtering, etc.

Usage:
python compute_timeseries_connectome.py \
  --fmri path/to/preproc_BOLD.nii.gz \
  --atlas path/to/atlas.nii.gz \
  --atlas_name Schaefer100 \
  --output_dir /path/to/output/ \
  --tag desc-preproc_options \
  --mode both \
  --confounds path/to/confounds.tsv \
  --confound_columns trans_x trans_y trans_z rot_x rot_y rot_z white_matter csf \ # MOTION
  --smoothing 4 \
  --drop_volumes 5 \
  --detrend \
  --low_pass 0.1 \
  --high_pass 0.01

Modes:
- both: compute both timeseries and connectome, and save both
- timeseries: compute both but only save the time series CSV
- connectome: compute both but only save the connectome CSV and figure
"""

import os
import argparse
import numpy as np
import nibabel as nib
import pandas as pd
from nilearn import image as nimg
from nilearn.input_data import NiftiLabelsMasker
from nilearn.connectome import ConnectivityMeasure
from nilearn import plotting

def compute_tr(fmri_file):
    tr_ms = nib.load(fmri_file).header.get_zooms()[3]
    return float(tr_ms) / 1000 if tr_ms > 150 else tr_ms

def extract_timeseries(fmri_file, atlas_file, tr, confounds=None, drop_vols=5, smoothing=0, detrend=False, low_pass=0.1, high_pass=0.01):
    print("[INFO] Preprocessing and extracting time series...")

    img = nimg.load_img(fmri_file)
    if smoothing > 0:
        img = nimg.smooth_img(img, fwhm=smoothing)

    img = img.slicer[:, :, :, drop_vols:]
    if confounds is not None:
        confounds = confounds.iloc[drop_vols:].reset_index(drop=True)

    masker = NiftiLabelsMasker(
        labels_img=atlas_file,
        standardize=True,
        detrend=detrend,
        low_pass=low_pass,
        high_pass=high_pass,
        t_r=tr
    )

    return masker.fit_transform(img, confounds=confounds)

def compute_connectome(time_series):
    print("[INFO] Computing functional connectivity matrix...")
    corr_measure = ConnectivityMeasure(kind='correlation')
    corr_matrix = corr_measure.fit_transform([time_series])[0]
    np.fill_diagonal(corr_matrix, 0)
    fisher_z = np.arctanh(corr_matrix)
    return corr_matrix, fisher_z

def main():
    parser = argparse.ArgumentParser(description="Extract timeseries and/or compute connectome with preprocessing")
    parser.add_argument('--fmri', required=True, help='Path to preprocessed BOLD fMRI image')
    parser.add_argument('--atlas', required=True, help='Path to parcellation atlas')
    parser.add_argument('--atlas_name', required=True, help='Short name for atlas')
    parser.add_argument('--output_dir', required=True, help='Directory to store output files')
    parser.add_argument('--tag', required=True, help='Custom tag to include in output filenames for gridsearch')
    parser.add_argument('--mode', choices=['timeseries', 'connectome', 'both'], default='both', help='What to compute and save')
    parser.add_argument('--confounds', default=None, help='Optional confounds .tsv file')
    parser.add_argument('--confound_columns', nargs='+', default=None, help='List of confound columns to include')
    parser.add_argument('--smoothing', type=float, default=0, help='FWHM smoothing kernel (mm)')
    parser.add_argument('--drop_volumes', type=int, default=5, help='Number of initial volumes to drop')
    parser.add_argument('--detrend', action='store_true', help='Apply linear detrending')
    parser.add_argument('--low_pass', type=float, default=0.1, help='Low-pass filter cutoff (Hz)')
    parser.add_argument('--high_pass', type=float, default=0.01, help='High-pass filter cutoff (Hz)')

    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    prefix_parts = os.path.basename(args.fmri).split("_task")
    subject_prefix = prefix_parts[0] if len(prefix_parts) > 0 else "sub"
    space_desc = "_space-MNI152NLin6Asym_desc-preproc"
    base_filename = f"{subject_prefix}{space_desc}_{args.tag}_atlas-{args.atlas_name}"

    ts_file = os.path.join(args.output_dir, base_filename + "_timeseries.csv")
    csv_file = os.path.join(args.output_dir, base_filename + "_connectome.csv")
    z_file = os.path.join(args.output_dir, base_filename + "_connectome_fisher_z.csv")
    fig_file = os.path.join(args.output_dir, base_filename + "_connectome_figure.jpg")

    tr = compute_tr(args.fmri)

    confounds = None
    if args.confounds and args.confound_columns:
        confound_df = pd.read_csv(args.confounds, sep='\t')
        try:
            confounds = confound_df[args.confound_columns]
        except KeyError as e:
            raise ValueError(f"One or more specified confound columns not found: {e}")

    time_series = extract_timeseries(
        args.fmri, args.atlas, tr, confounds,
        drop_vols=args.drop_volumes, smoothing=args.smoothing,
        detrend=args.detrend, low_pass=args.low_pass, high_pass=args.high_pass
    )

    if args.mode in ['both', 'timeseries']:
        pd.DataFrame(time_series).to_csv(ts_file, index=False)
        print(f"[INFO] Time series saved: {ts_file}")

    if args.mode in ['both', 'connectome']:
        corr_matrix, fisher_z = compute_connectome(time_series)
        np.savetxt(csv_file, corr_matrix, delimiter=",")
        np.savetxt(z_file, fisher_z, delimiter=",")
        plotting.plot_matrix(corr_matrix, reorder=False).figure.savefig(fig_file, dpi=300)
        print(f"[INFO] Connectome saved: {csv_file}")
        print(f"[INFO] Fisher Z saved: {z_file}")
        print(f"[INFO] Plot saved: {fig_file}")

if __name__ == '__main__':
    main()