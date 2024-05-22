
# EuroPAD Imaging Directory

Author: L. Pieperhoff (l.pieperhoff@amsterdamumc.nl)
Date: 2024-05-22

This GIT repository is a collection of scripts used in the (pre-)processing and phenotype-extraction from Magnetic Resonance Imaging and Positron Emission Tomography images in EuroPAD (European Prevention of Alzheimer's Disease), a consortium in the making. EuroPAD consists, among other things, of:
Current main effort lies in merging and storing all imaging data of the following datasets:
1. EPAD: https://ep-ad.org/
2. EMIF-AD: https://www.emif.eu/emif-ad-2/
3. AMYPAD-PNHS: https://amypad.eu

The provided scripts and atlases aim to support open-science practices and increase replicability and understanding of the neuroimaging data utilized in EuroPAD.

## How to Use
**needs to be written properly**
Clone this directory into your BIDS-conforming study directory under studydir/code, then read corresponding README.md to understand how to utilize specific scripts.
To understand how to structure your data, see https://bids.neuroimaging.io 


## For collaborators: add this piece of text in front of code:
`

#!/bin/bash
# Script Description here
# BASH Dependencies:
module load ...

codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=$(realpath $(echo $codedir/../../..)) # location of BIDS directory
atlasname= # name of atlas file here

`