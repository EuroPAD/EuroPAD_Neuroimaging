#!/bin/bash
#SBATCH --job-name=tractography
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=16G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-5:00:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

## Step 13 of extra processing steps to be done on qsiprep output for performing fixel analysis

#1.Perform tractography on template

#load modules
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# settings
#fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
fixeldir=/scratch/radv/mtranfa/fod_template_tractography

# run tractography on the template 
echo "running tractography on template"
cd $fixeldir
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 fod_template.mif -seed_image group_mask_intersection.mif -mask group_mask_intersection.mif -select 20000000 -cutoff 0.06 tracks_20_million.tck -nthreads 12

# SIFT
echo "running SIFT"
tcksift tracks_20_million.tck fod_template.mif tracks_2_million_sift.tck -term_number 2000000 -nthreads 12 # filter

# Fixel-to-fixel Connectivity
echo "computing fixel-to-fixel connectivity"
fixelconnectivity fixel_mask/ tracks_2_million_sift.tck matrix/ 
