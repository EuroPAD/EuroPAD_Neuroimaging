#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 18:06:15 2023

@author: llorenzini
"""
### Connectome Computation
# import all relevant general modules
import sys
import os 
import argparse
import numpy as np
import nibabel as nib

def main():

    # parse options
    parser = argparse.ArgumentParser(description="denoise using the ICAAROMA strategy [Pruim2015, Ciric2017] and build functional connectome")
    parser.add_argument ( "fmrifile", help="preprocessed fMRI from fmriprep")
    parser.add_argument ( "-a", "--atlasfile", help="brain parcellation in the same space of fMRI")
    parser.add_argument ( "-n", "--atlasname", help="atlas name")
    args = parser.parse_args()    
    
    # Define variables
    fmri_filename = args.fmrifile
    atlas_filename = args.atlasfile
    atlas_name = args.atlasname
    #fmri_filename="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/fmriprep/sub-010EPAD24260/ses-01/func/sub-010EPAD24260_ses-01_task-rest_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"
    #atlas_filename="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/schaeffer_100_2mm.nii.gz"
    
    ## ARMOA ONLY NEEDS TO BE RUN ON NATIVE SPACE (or on MNIlin2009)
    if "AROMA" in fmri_filename:
        use_aroma=0
        
    else:
        use_aroma=1
        from load_confounds import ICAAROMA
        raw_confounds = ICAAROMA().load(fmri_filename);
        confounds = raw_confounds[4:]
        
        
    # Drop first 4 timepoints from both image and confounds (non steady-state volumes)
    from nilearn import image as nimg       
    raw_func_img = nimg.load_img(fmri_filename)
    func_img = raw_func_img.slicer[:,:,:,4:]

      
    #READ TR
    tr_ms = nib.load(fmri_filename).header.get_zooms()[3]
    if tr_ms > 150:
        # knowing that no tr is that long, we assume milliseconds and convert to seconds
        tr = float(tr_ms) / 1000
    else:
        # it must be in seconds
        tr = tr_ms
        
    

#######################################################################################
    # Extract signals on a parcellation defined by labels and build functional connectome
    # -----------------------------------------------------
    
    #print ("\nbuilding functional connectome for %s\n" % atlas_name)

    csv_basename = os.path.basename (fmri_filename).replace (".nii.gz","_" + atlas_name + "_connectome.csv") 
    csv_filename = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), csv_basename)
    csv_basename_fisher_z = os.path.basename (fmri_filename).replace (".nii.gz","_" + atlas_name + "_connectome_fisher_z.csv") 
    csv_filename_fisher_z = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), csv_basename_fisher_z)
    
    
    


  
    if not os.path.exists(csv_filename_fisher_z):
        # Use the NiftiLabelsMasker to compute timeseries for each parcel
        from nilearn.input_data import NiftiLabelsMasker
        masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True, detrend=False, low_pass=0.08, t_r=tr)
#       
        if use_aroma:
            time_series = masker.fit_transform(func_img, confounds=confounds) 
        else:
            time_series = masker.fit_transform(func_img)

        # compute the correlation matrix
        from nilearn.connectome import ConnectivityMeasure
        correlation_measure = ConnectivityMeasure(kind='correlation')
        correlation_matrix = correlation_measure.fit_transform([time_series])[0]
        np.fill_diagonal(correlation_matrix, 0)
        correlation_matrix_fisher_z = np.arctanh(correlation_matrix)

        # save correlation matrices in csv files
        np.savetxt(csv_filename, correlation_matrix, delimiter=",")
        np.savetxt(csv_filename_fisher_z, correlation_matrix_fisher_z, delimiter=",")

        # save plot of correlation matrix
        from nilearn import plotting
        plot = plotting.plot_matrix(correlation_matrix, reorder=False)
        plot_basename = os.path.basename (fmri_filename).replace (".nii.gz","_" + atlas_name + "_connectome_figure.jpg")
        plot_filename = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), plot_basename)
        plot.figure.savefig(plot_filename, dpi=300)
        
    else:
        print("Connectome already computed for file", fmri_filename, "with atlas ", atlas_name)
            
# if nothing else has been done yet, call main()    
if __name__ == '__main__': 
    main()
