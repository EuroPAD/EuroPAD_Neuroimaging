#!/bin/bash
#SBATCH --job-name=fod2fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=5G             # max memory per node
# Request 7 hours run time
#SBATCH -t 0-00:30:0
#SBATCH --partition=luna-short  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario

# Take the intersection of the masks and create a group mask
mrmath $fixeldir/subjects/*/ses-01/dwi/sub*space-FODtemplate_brain_mask.mif min $fixeldir/template/group_mask_intersection.mif -datatype bit -force

# Compute fixels on group template within the group mask
rm -rd  $fixeldir/template/fixel_mask/
fod2fixel -mask $fixeldir/template/group_mask_intersection.mif -fmls_peak_value 0.06 $fixeldir/template/fod_template.mif $fixeldir/template/fixel_mask -force
