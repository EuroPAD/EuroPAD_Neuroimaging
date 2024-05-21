#!/usr/bin/env python3

"""
Denoising fMRI files using AROMA outputs
=============================================================================================
"""

# import all relevant general modules
import sys
import os 
import argparse
import numpy as np
import nibabel as nib
import ants
import load_confounds

def main():

    # parse options
    parser = argparse.ArgumentParser(description="denoise using the ICAAROMA strategy [Pruim2015, Ciric2017] and build functional connectome")
    parser.add_argument ( "fmrifile", help="preprocessed fMRI from fmriprep")
    parser.add_argument ( "-a", "--atlasfile", help="brain parcellation in the same space of fMRI")
    args = parser.parse_args()



    # Define variables
    fmri_filename = args.fmrifile
    atlas_filename = args.atlasfile

    print ("\nstarting ICAAROMA denoising for %s\n" % args.fmrifile)
            # get repetition time from nifti header (needed for low-pass filtering)
    
    
    # READ CONFOUNDS
    from load_confounds import ICAAROMA
    raw_confounds = ICAAROMA().load(fmri_filename);

    # Drop first 4 timepoints from both image and confounds (non steady-state volumes)
    from nilearn import image as nimg       
    raw_func_img = nimg.load_img(fmri_filename)
    func_img = raw_func_img.slicer[:,:,:,4:]
    confounds = raw_confounds[4:]

    
    
    #READ TR
    tr_ms = nib.load(fmri_filename).header.get_zooms()[3]
    if tr_ms > 150:
        # knowing that no tr is that long, we assume milliseconds and convert to seconds
        tr = float(tr_ms) / 1000
    else:
        # it must be in seconds
        tr = tr_ms

    ## IF ALREADY DONE SKIP ####
    
    if not os.path.exists(os.path.abspath (fmri_filename).replace ("AROMAnonaggr_bold.nii.gz","ICAAROMAdenoised.nii.gz")):
        # Filter confounds from fmriprep output according to our denoising strategy
   

    
        # clean and save img
        clean_img = nimg.clean_img(func_img, confounds=confounds, standardize=True, detrend=False, low_pass=0.08, t_r=tr)
        clean_img_filename = os.path.abspath (fmri_filename).replace ("AROMAnonaggr_bold.nii.gz","ICAAROMAdenoised.nii.gz");
        clean_img.to_filename(clean_img_filename)
    else:
        print("Denoised already run for %s\n" % args.fmrifile)


    #######################################################################################
    # Extract signals on a parcellation defined by labels and build functional connectome
    # -----------------------------------------------------
    if args.atlasfile is not None:
        
        print ("\nbuilding functional connectome for %s\n" % args.atlasfile)
        csv_basename = os.path.basename (atlas_filename).replace (".nii.gz","_connectome.csv") 
        csv_filename = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), csv_basename)
        csv_basename_fisher_z = os.path.basename (atlas_filename).replace (".nii.gz","_connectome_fisher_z.csv") 
        csv_filename_fisher_z = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), csv_basename_fisher_z)

        if not os.path.exists(csv_filename_fisher_z):
            # Use the NiftiLabelsMasker to compute timeseries for each parcel
            from nilearn.input_data import NiftiLabelsMasker
            masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True, detrend=False, low_pass=0.08, t_r=tr)
            time_series = masker.fit_transform(func_img, confounds=confounds)
    
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
            plot_basename = os.path.basename (atlas_filename).replace ("nii.gz","connectome_figure.jpg")
            plot_filename = os.path.abspath (fmri_filename).replace (os.path.basename (fmri_filename), plot_basename)
            plot.figure.savefig(plot_filename, dpi=300)

        else:
            print("Connectome was already built for %s\n" % args.atlasfile)


# if nothing else has been done yet, call main()    
if __name__ == '__main__': 
    main()
