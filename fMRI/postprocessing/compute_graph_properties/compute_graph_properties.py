#!/usr/bin/env python3
"""
Script to compute graph properties from brain connectome matrices (CSV format).
Handles functional, structural, and anatomical (MIND) connectomes.
Outputs global metrics, regional node-level metrics, and matrices.

Outputs per subject/session include:
- Global graph metrics CSV
- Regional node metrics: strength, degree, betweenness, clustering, eigenvector, nodal efficiency, participation, wmd
- Matrices: shortest paths, communicability
- Heatmaps: connectome, communicability
- Optional group-level summary CSV for global metrics
"""

# ======== IMPORT LIBRARIES ======== #
import os
import argparse
import numpy as np
import pandas as pd
import networkx as nx
import bct
import seaborn as sns
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from datetime import datetime
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning)

# ======== PARSE ARGUMENTS ======== #
def parse_arguments():
    parser = argparse.ArgumentParser(description="Compute graph properties from connectome CSV files")
    parser.add_argument('--connectome_type', type=str, required=True, choices=['functional_connectome', 'structural_connectome', 'MIND_connectome'], help='Type of connectome')
    parser.add_argument('--pipeline_type', type=str, required=True, help='Pipeline type, e.g. fmriprep-v23.0.1')
    parser.add_argument('--atlas_name', type=str, required=True, help='Atlas name used for the connectome')
    parser.add_argument('--base_dir', type=str, required=True, help='Base directory of the project')
    parser.add_argument('--threshold', type=float, default=0.2, help='Threshold for functional connectomes (default: 0.2)')
    parser.add_argument('--atlas_dir', type=str, required=True, help='Directory containing atlas files')
    parser.add_argument('--atlas_labels_file', type=str, required=True, help='Text file with ROI labels')
    parser.add_argument('--input_csv_list', type=str, required=True, help='List of connectome CSVs to process')
    parser.add_argument('--results_folder', type=str, required=True, help='Output directory to store results')
    return parser.parse_args()

# ======== MAIN FUNCTION ======== #
def main():
    args = parse_arguments()

    CONNECTOME_TYPE = args.connectome_type
    PIPELINE_TYPE = args.pipeline_type
    ATLAS_NAME = args.atlas_name
    BASE_DIR = args.base_dir
    THRESHOLD = args.threshold
    ATLAS_DIR = args.atlas_dir
    ATLAS_LABELS_FILE = args.atlas_labels_file
    INPUT_CSV_LIST = args.input_csv_list
    RESULTS_FOLDER = args.results_folder

    os.makedirs(RESULTS_FOLDER, exist_ok=True)

    atlas_info = pd.read_csv(ATLAS_LABELS_FILE, sep=',', header=None)
    node_labels = atlas_info.iloc[1:, 1].values

    REGIONAL_COLLECTION = {'strength': [], 'degree': [], 'betweenness': [], 'clustering': [],
        'eigenvector': [], 'nodal_efficiency': [], 'participation': [], 'wmd': []}

    def load_matrix(file_path, conn_type):
        mat = pd.read_csv(file_path, header=None).values
        mat[np.isnan(mat)] = 0
        np.fill_diagonal(mat, 0)

        if conn_type == "functional_connectome":
            mat = np.abs(mat)
            non_zero = mat[mat > 0]
            if len(non_zero) > 0:
                thresh = np.quantile(non_zero, THRESHOLD)
                mat[mat < thresh] = 0
        elif conn_type == "structural_connectome":
            mat = np.log1p(mat)
            mat[mat < 1] = 0
        elif conn_type == "MIND_connectome":
            pass  # no transformation
        return mat

    def compute_global_metrics(mat):
        D = bct.distance_wei(mat)[0]
        cp = bct.charpath(D)[0]
        GE = bct.efficiency_wei(mat)
        CC = np.mean(bct.clustering_coef_wu(mat))
        strength = bct.strengths_und_sign(mat)[0]
        betweenness = bct.betweenness_wei(D)
        density, nVertices, nEdges = bct.density_und(mat)
        try:
            Q = bct.modularity_louvain_und(mat)[1]
        except Exception as e:
            print(f"\u26a0\ufe0f Modularity computation failed: {e}")
            Q = np.nan
        return {
            'char_path_len': cp,
            'global_efficiency': GE,
            'avg_clustering_coef': CC,
            'modularity_Q': Q,
            'density': density,
            'nVertices': nVertices,
            'nEdges': nEdges,
            'avg_strength': np.mean(strength),
            'avg_betweenness': np.mean(betweenness)
        }

    def compute_local_metrics(mat):
        strength = bct.strengths_und_sign(mat)[0]
        degree = np.sum(mat > 0, axis=0)
        btwn = bct.betweenness_wei(bct.distance_wei(mat)[0])
        cluster = bct.clustering_coef_wu(mat)
        G_nx = nx.from_numpy_array((mat > 0).astype(int))
        eigen = list(nx.eigenvector_centrality_numpy(G_nx, weight='weight').values())
        nodal_eff = bct.efficiency_wei(mat, local=True)
        comm_dict = nx.communicability_exp(G_nx)
        comm = pd.DataFrame(comm_dict).T
        comm.columns = node_labels
        comm.index = node_labels
        return {
            'strength': pd.Series(strength, index=node_labels),
            'degree': pd.Series(degree, index=node_labels),
            'betweenness': pd.Series(btwn, index=node_labels),
            'clustering': pd.Series(cluster, index=node_labels),
            'eigenvector': pd.Series(eigen, index=node_labels),
            'nodal_efficiency': pd.Series(nodal_eff, index=node_labels),
            'communicability': comm
        }

    def compute_small_worldness(mat, n_rand=20, rewire_param=10):
        D = bct.distance_wei(mat)[0]
        L = bct.charpath(D)[0]
        C = np.mean(bct.clustering_coef_wu(mat))
        C_rand = []
        L_rand = []
        for _ in range(n_rand):
            rand_mat = bct.randmio_und(mat.copy(), rewire_param)[0]
            D_rand = bct.distance_wei(rand_mat)[0]
            C_rand.append(np.mean(bct.clustering_coef_wu(rand_mat)))
            L_rand.append(bct.charpath(D_rand)[0])
        Gamma = C / np.mean(C_rand)
        Lambda = L / np.mean(L_rand)
        sigma = Gamma / Lambda
        return {'Gamma': Gamma, 'Lambda': Lambda, 'SW_coeff': sigma}

    def compute_participation_wmd(mat):
        try:
            community = bct.modularity_louvain_und(mat)[0]
            pc = bct.participation_coef(mat, community)
            wmd = bct.module_degree_zscore(mat, community)
        except Exception as e:
            print(f"\u26a0\ufe0f Participation/WMD computation failed: {e}")
            pc = np.full(mat.shape[0], np.nan)
            wmd = np.full(mat.shape[0], np.nan)
        return pc, wmd

    def compute_shortest_paths(mat):
        return bct.distance_wei(mat)

    def plot_connectome_heatmap(mat, subj, ses, output_dir, label):
        plt.figure(figsize=(8, 6))
        sns.heatmap(mat.astype(float), cmap='viridis', square=True)
        plt.title(f"{label} Matrix - {subj} {ses}")
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, f"{subj}_{ses}_{label.replace(' ', '_')}_heatmap.png"))
        plt.close()

    def plot_metric_distribution(series, column, subj, ses, output_dir):
        clean = series.replace([np.inf, -np.inf], np.nan).dropna()
        if clean.empty:
            print(f"\u26a0\ufe0f Skipping plot for {column} (all values were NaN or Inf)")
            return
        plt.figure(figsize=(8, 5))
        sns.histplot(clean, bins=20, kde=True)
        plt.title(f"Distribution: {column} - {subj} {ses}")
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, f"{subj}_{ses}_{ATLAS_NAME}_{column}_dist.png"))
        plt.close()

    def process_subject(file_path, conn_type, output_dir):
        mat = load_matrix(file_path, conn_type)
        basename = os.path.basename(file_path)
        subj = basename.split("_")[0]
        ses = basename.split("_")[1] if "_" in basename else "ses-1"

        print(f"[{datetime.now().strftime('%H:%M:%S')}] {conn_type.title()} connectome: {subj}, {ses}")

        subj_out = os.path.join(output_dir, subj, ses)
        os.makedirs(subj_out, exist_ok=True)

        base_prefix = f"{subj}_{ses}_desc-{ATLAS_NAME}"

        if os.path.exists(os.path.join(subj_out, f"{base_prefix}_global.csv")):
            print(f"Skipping recomputation for {subj} {ses} — already computed.")
    
         # --- Read already computed files and return the metrics to append --- #
            try:
                global_metrics = pd.read_csv(os.path.join(subj_out, f"{base_prefix}_global.csv")).iloc[0].to_dict()
                global_metrics['subject'] = subj
                global_metrics['session'] = ses
                reg_metrics = {}

                for metric_name in REGIONAL_COLLECTION.keys():
                    regional_file = os.path.join(subj_out, f"{base_prefix}_regional_{metric_name}.csv")
                    if os.path.exists(regional_file):
                        df = pd.read_csv(regional_file)
                        reg_metrics[metric_name] = df.drop(columns=["subject", "session"]).squeeze()
                    else:
                        print(f"Missing regional metric: {metric_name} for {subj} {ses}")
    
                return global_metrics, reg_metrics
            except Exception as e:
                print(f"Failed to load existing metrics for {subj} {ses}: {e}")
                return None

        global_metrics = compute_global_metrics(mat)
        sw_metrics = compute_small_worldness(mat)
        global_metrics.update(sw_metrics)
        global_metrics = {'subject': subj, 'session': ses, **global_metrics}

        reg_metrics = compute_local_metrics(mat)
        pc, wmd = compute_participation_wmd(mat)
        reg_metrics['participation'] = pd.Series(pc, index=node_labels)
        reg_metrics['wmd'] = pd.Series(wmd, index=node_labels)

        sp_matrix = compute_shortest_paths(mat)[0]
        sp_df = pd.DataFrame(sp_matrix, columns=node_labels, index=node_labels)

        pd.DataFrame([global_metrics]).to_csv(os.path.join(subj_out, f"{base_prefix}_global.csv"), index=False)

        for metric_name, series in reg_metrics.items():
            if metric_name == 'communicability':
                series.to_csv(os.path.join(subj_out, f"{base_prefix}_regional_communicability.csv"), index=True, header=True)
                plot_connectome_heatmap(series.values.astype(float), subj, ses, subj_out, label=f"{ATLAS_NAME}_Communicability")
            else:
                row = pd.DataFrame([series.values], columns=node_labels)
                row.insert(0, 'session', ses)
                row.insert(0, 'subject', subj)
                row.to_csv(os.path.join(subj_out, f"{base_prefix}_regional_{metric_name}.csv"), index=False)
                REGIONAL_COLLECTION[metric_name].append(row)
                if metric_name in ['strength', 'nodal_efficiency']:
                    plot_metric_distribution(series, metric_name, subj, ses, subj_out)

        sp_df.to_csv(os.path.join(subj_out, f"{base_prefix}_shortest_paths.csv"), index=True, header=True)
        plot_connectome_heatmap(mat, subj, ses, subj_out, label=f"{ATLAS_NAME}_Connectome")

        return global_metrics, reg_metrics 

    all_globals = []

    if not os.path.exists(INPUT_CSV_LIST):
        raise FileNotFoundError(f"CSV list not found: {INPUT_CSV_LIST}")

    with open(INPUT_CSV_LIST, 'r') as f:
        files = [line.strip() for line in f if line.strip()]

    for fpath in files:
        if not os.path.exists(fpath):
            print(f"⚠\ufe0f Skipping missing file: {fpath}")
            continue
        result = process_subject(fpath, CONNECTOME_TYPE, RESULTS_FOLDER)
        if result is not None:
            gm, reg = result
            all_globals.append(gm)
            for metric_name, series in reg.items():
                if metric_name in ['communicability', 'shortest_paths']:
                    # Skip or handle communicability separately
                    continue
                row = pd.DataFrame([series.values], columns=node_labels)
                row.insert(0, 'session', gm['session'])
                row.insert(0, 'subject', gm['subject'])
                REGIONAL_COLLECTION[metric_name].append(row)

    # -------- Append global metrics if not already present -------- #
    global_csv_path = os.path.join(RESULTS_FOLDER, f"global_metrics_all_{PIPELINE_TYPE}_{ATLAS_NAME}.csv")
    if all_globals:
        df_new = pd.DataFrame(all_globals)
    if os.path.exists(global_csv_path):
        df_existing = pd.read_csv(global_csv_path)
        df_combined = pd.concat([df_existing, df_new], ignore_index=True)
        df_combined = df_combined.drop_duplicates(subset=["subject", "session"])
    else:
        df_combined = df_new
    df_combined.to_csv(global_csv_path, index=False)

# -------- Append regional metrics if not already present -------- #
    for metric, rows in REGIONAL_COLLECTION.items():
        if rows:
            combined_new = pd.concat(rows, ignore_index=True)
            regional_csv_path = os.path.join(RESULTS_FOLDER, f"regional_metrics_all_{metric}_{PIPELINE_TYPE}_{ATLAS_NAME}.csv")
            if os.path.exists(regional_csv_path):
                combined_existing = pd.read_csv(regional_csv_path)
                combined_all = pd.concat([combined_existing, combined_new], ignore_index=True)
                combined_all = combined_all.drop_duplicates(subset=["subject", "session"])
            else:
                combined_all = combined_new
            combined_all.to_csv(regional_csv_path, index=False)

    print(f"\nDone. All results saved to: {RESULTS_FOLDER}/")

if __name__ == "__main__":
    main()