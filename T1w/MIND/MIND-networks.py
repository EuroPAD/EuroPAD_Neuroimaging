#!/usr/bin/env python3

"""
Compute MIND networks from freesurfer reconstruction
=============================================================================================
"""

# import all relevant modules
from os.path import join as opj
from os.path import basename
import argparse
import sys
sys.path.insert(1, '/home/radv/parunachalam/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/T1w/MIND/MIND')
from MIND import compute_MIND

def main():
  
    # parse options
    parser = argparse.ArgumentParser(description="Compute MIND network from freesurfer reconstruction")
    parser.add_argument ( "freesurfer_dir", help="absolute path of freesurfer folder containing all standard output directories")
    parser.add_argument ( "-o", "--output", help="output directory")
    ## Select which parcellation to use. This has been tested on Desikan Killiany (DK), HCP-Glasser, DK-308 and DK-318 parcellations.
    parser.add_argument("--atlas", default="Schaefer2018_100Parcels_7Networks_order", help="Name of parcellation atlas")
    args = parser.parse_args()

    # Define variables
    path_to_surf_dir = args.freesurfer_dir
    output_dir = args.output

    ## Specify features to include in MIND calculation. Any combination of the following five features are currently supported.
    features = ['CT','MC','Vol','SD','SA'] 

    ...
    parcellation = args.atlas

    ## Returns a dataframe of regions X regions containing the final MIND network.
    MIND = compute_MIND(path_to_surf_dir, features, parcellation) 
    matrix_filename = f"{basename(path_to_surf_dir)}_MIND-{args.atlas}.csv"
    MIND.to_csv(opj(output_dir, matrix_filename), sep=',', header=True, index=True)
    
# if nothing else has been done yet, call main()    
if __name__ == '__main__': 
    main()
