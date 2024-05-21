#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 21 14:23:14 2022

@author: llorenzini
"""

# Currently support two atlases for extraction, Smiths and Yeo (17). 
# Does not work with melodic maps yet

#%%
# import libraries
import pandas as pd
import numpy as np
import os
import subprocess
import ants
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import h5py
import nibabel as nib
from nilearn import plotting 

# Settings 

# Change here according to the atlas you used for the DR
atlas = "Yeo17"  # "Smith"
drfold = "/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DualRegression_Yeo17/"

if atlas == "Yeo17":
    atlasfile="/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/yeo-17-liberal_network_4D_2mm_bin.nii.gz"
    thr = 0.99 ## YEO is binary
    rsn = {'rsn_num' : [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
           'rsn_name' : ['VisCent', 'VisPeri', 'SomMotA', 'SomMotB', 'DorsAttnA', 'DorsAttnB', 'SalVentAttnA', 'SalVenAttnB', 'LimbicB', 'LimbicA', 'ContC', 'ContA', 'ContB',  'TempPar', 'DefaultC', 'DefaultA', 'DefaultB']}
    rsndf = pd.DataFrame(rsn)
elif   atlas == "Smith":
    atlasfile="/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/PNAS_Smith09_rsn10.nii.gz"
    thr = 3 ## YEO is binary
    rsn = {'rsn_num' : [0,1,2,3,4,5,6,7,8,9],'rsn_name' : ['Vis1', 'Vis2', 'Vis3', 'Def', 'Cereb', 'Somato', 'Audit', 'Exec', 'FPN1', 'FPN2']}
    rsndf = pd.DataFrame(rsn)



## Read Input Files
# Nifti
atlas = ants.image_read(atlasfile)


# Txt
files = pd.read_csv(os.path.join(drfold, 'fmri_inputs.txt'), header=None)
files.columns = ['files']
files['Subject'] = files['files'].str[85:97] ## STUDY SPECIFIC
files['Ses'] = files['files'].str[98:104] ## STUDY SPECIFIC

files.drop('files', inplace=True, axis=1)



# Within RSN connectivity
withindf  = np.zeros(shape=(len(files), atlas.shape[3]))  # change here to find number of subjects and number of components


# Read Atlas
atlas = nib.load(atlasfile).get_fdata()

# iterate across components
for nc in range(atlas.shape[3]):
    atlas_again = nib.load(atlasfile).get_fdata() # for some reason it gets screwed up when we operate on it
    print(["processing Component " + str(nc)])
    c1 = atlas_again[:,:,:, nc]
    c1[c1 < thr] = 0 
    c1[c1 > 0] = 1

    
    c1drout = os.path.join(drfold, "dr_stage2_ic" + str(nc).zfill(4) + ".nii.gz")
    compimg = ants.image_read(c1drout)


    ## Iterate across volumes (subjects)
    for i in range(compimg.shape[3]):
        print(["processing Subject " + str(i)])
        subvol = compimg[:,:,:,i]
        subvol = stats.zscore(subvol) #Z SCORE WITHIN the subject ?
        subvol_mask = subvol[c1 == 1]
        withindf[i,nc] = np.nanmean(subvol_mask)

withindf = pd.DataFrame(withindf)
withindf.columns = rsndf.rsn_name
withindf['Subject'] = files['Subject']
withindf['Ses'] = files['Ses']


withindf.to_csv(os.path.join(drfold, 'within_RSN_conn.csv'))

### Between RSN Connectivity
betweendf = pd.DataFrame()

for i in range(len(files)):
    print(["processing Subject " + str(i)])

    rsnts = np.genfromtxt(os.path.join(drfold, 'dr_stage1_subject' + str(i).zfill(5) + '.txt'))
    CC = np.corrcoef(rsnts.transpose())
    CM = pd.DataFrame(CC, index = rsndf.rsn_name, columns= rsndf.rsn_name)

    # Get unique values of the CM with names
    CM_out = CM.stack()
    CM_out = CM_out[CM_out.index.get_level_values(0) != CM_out.index.get_level_values(1)]
    CM_out = CM_out[CM_out.index.get_level_values(0) < CM_out.index.get_level_values(1)]
    CM_out.index = CM_out.index.map('_'.join)
    CM_out = CM_out.to_frame().T

    # Append
    betweendf = betweendf.append(CM_out)

betweendf = betweendf.reset_index()
betweendf = betweendf.drop('index', axis = 1 )
betweendf['Subject'] = files['Subject']
betweendf['Ses'] = files['Ses']

betweendf.to_csv(os.path.join(drfold, 'between_RSN_conn.csv'))


# v1 = atlas[:,:,20, 0]
# plt.imshow(v1)
# sns.heatmap(v1, cmap = "bwr")

#plotting.plot_matrix(CC, vmax = 1, vmin = -1, colorbar = True)


# v1 = compimg[:,:,50, 150]
# plt.imshow(v1)
# sns.heatmap(v1, cmap = "bwr")


# v1 = compimg[:,:,50, 150]
# plt.imshow(v1)
# sns.heatmap(v1, cmap = "bwr")

