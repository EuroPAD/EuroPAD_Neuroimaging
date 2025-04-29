#!/bin/bash
## Step 14 of extra processing steps to be done on qsiprep output for performing fixel analysis

#1. Perform smoothing based on fixel-to-fixel connectivity to improve fixel statistics
   
#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC

cd $fixeldir/template

echo "Smoothing fixels based on fixel-to-fixel connectivity"

# Fixel filtering (smoothing)
fixelfilter fd smooth fd_smooth -matrix matrix/ -nthreads 12

fixelfilter log_fc smooth log_fc_smooth -matrix matrix/ -nthreads 12

fixelfilter fdc smooth fdc_smooth -matrix matrix/ -nthreads 12

echo "Smoothing is done - have fun!"
