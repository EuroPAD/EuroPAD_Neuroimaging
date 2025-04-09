#!/bin/bash
#SBATCH --job-name=FixAnalysis
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G             # max memory per node
# Request 7 hours run time
#SBATCH -t 01:00:0
#SBATCH --partition=luna-short  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000                     # be nice

module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

cd /home/radv/$(whoami)/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels/template/
#Remove files from previous analysis
rm -r ./neg_stats*
rm -r ./pos_stats*

#Negative contrast, prs
fixelcfestats fd_smooth/ files.txt design_matrix.txt negative_contrast_amyloid.txt matrix/ neg_stats_fd/ -force


#fixelcfestats log_fc_smooth/ files.txt design_matrix.txt negative_contrast_amyloid.txt matrix/ neg_stats_log_fc/ -force
#fixelcfestats fdc_smooth/ files.txt design_matrix.txt negative_contrast_amyloid.txt matrix/ neg_stats_fdc/ -force

#Positive contrast, A+ > A-
#fixelcfestats fd_smooth/ -nshuffles 50 files.txt design_matrix.txt positive_contrast_amyloid.txt matrix/ pos_stats_fd/ -force

#fixelcfestats log_fc_smooth/ files.txt design_matrix.txt positive_contrast_amyloid.txt matrix/ pos_stats_log_fc/ -force
#fixelcfestats fdc_smooth/ files.txt design_matrix.txt positive_contrast_amyloid.txt matrix/ pos_stats_fdc/ -force
