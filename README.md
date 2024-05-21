
# EuroPAD Imaging Directory

Author: L. Pieperhoff (l.pieperhoff@amsterdamumc.nl)
Date: 2024-04-27

This directory is a collection of multi-site datasets, in the spirit of EuroPAD (European Prevention of Alzheimer's Disease), a consortium in the making.
Current main effort lies in merging and storing all imaging data of the following datasets:
    1. EPAD: https://ep-ad.org/
    2. EMIF-AD: https://www.emif.eu/emif-ad-2/
    3. AMYPAD-PNHS: https://amypad.eu

One of the major advantages of storing the imaging data of these cohorts together is in saving storage space and reducing processing efforts. Many participants of EPAD and EMIF-AD are also part of the AMYPAD-PNHS dataset, storing all of this data twice would result in significant storage costs. Through the use of small-sized hash tables containing subjects' EPAD and AMYPAD ID's, for example, extraction of data of one subject can be done for both datasets.


put this directory into studydir/code, according to BIDS structure.
realpath $BASH_SOURCE/../../rawdata

## script formula:

#!/bin/bash
# Script Description here
# Bash Dependencies:
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load fsl

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=$(realpath $(echo $codedir/../../..)) # location of BIDS directory
