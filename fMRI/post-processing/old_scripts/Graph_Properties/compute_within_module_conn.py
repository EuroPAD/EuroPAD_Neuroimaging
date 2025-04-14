#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 13 11:45:14 2023

@author: llorenzini
"""

"""
Compute within module connectivity for each node

Created by Luigi Lorenzini
"""

# Import libraries
import numpy as np
import pandas as pd
import scipy
from scipy.linalg import block_diag
import bct
import os
import matplotlib.pyplot as plt
import glob
from nilearn import plotting 
import sys


# Define data

#bidsdir="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD"
filelist="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI/Graph/fulllist.txt"
# opening the file in read mode 
my_file = open(filelist, "r") 
  
# reading the file 
data = my_file.read() 

data_list = data.split("\n")

atlas_info = pd.read_csv("/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaefer2018_100Parcels_7Networks_order.txt", sep = '\t', header=None).to_numpy() # Scheafer 100 is used
area_names = atlas_info[:,1]
datadir =os.path.dirname(data_list[0])

## THRESHOLD SET UP
threshold=0.3
str(threshold)

resultdir = os.path.join(datadir, "Graph_Properties_" + str(threshold))

