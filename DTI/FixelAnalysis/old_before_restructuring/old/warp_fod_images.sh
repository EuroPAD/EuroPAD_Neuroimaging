#!/bin/bash
#SBATCH --job-name=fod2fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=10G             # max memory per node
# Request 7 hours run time
#SBATCH -t 4-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario
#QSIPREP=/home/radv/mtranfa/qsiprep-0.19.0.sif

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# Warp subjects FOD images in to template space, without reorientation of FODs (performed later)
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrtransform ${qsirecdir}/NAME/ses-01/dwi/NAME_ses-01_group_average_response_wmfod_norm.mif -warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif -reorient_fod no $fixeldir/subjects/NAME/ses-01/dwi/NAME_ses-01_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif -force

### Include all subjects from now on
# Segment subjects' FOD images, to estimate fixels and apparent fibers density
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_wmFixels_not_reoriented
for_each $fixeldir/subjects/* : fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels_not_reoriented -afd fd.mif -force

# Now reorient the fixels based on local transformation taken from previous warps
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_wmFixels
for_each $fixeldir/subjects/* : fixelreorient IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels_not_reoriented IN/ses-01/dwi/NAME_to_template.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels

# match fixels from each individual to te template ones
rm $fixeldir/template/fd/index.mif
rm $fixeldir/template/fd/directions.mif
for_each $fixeldir/subjects/* : fixelcorrespondence IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels/fd.mif $fixeldir/template/fixel_mask $fixeldir/template/fd PRE.mif -force

# Compute Fibre crossection (FC) from the warps
rm $fixeldir/template/fc/index.mif
rm $fixeldir/template/fc/directions.mif
for_each $fixeldir/subjects/* : warp2metric IN/ses-01/dwi/NAME_to_template.mif -fc $fixeldir/template/fixel_mask $fixeldir/template/fc PRE.mif -force

# Log FC
if [[ ! -d $fixeldir/template/log_fc ]]; then 
mkdir $fixeldir/template/log_fc
fi
cp $fixeldir/template/fc/index.mif $fixeldir/template/log_fc
cp $fixeldir/template/fc/directions.mif $fixeldir/template/log_fc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fc/PRE.mif -log $fixeldir/template/log_fc/PRE.mif -force

# Compute FDC
if [[ ! -d $fixeldir/template/fdc ]]; then
mkdir $fixeldir/template/fdc
fi
cp $fixeldir/template/fc/index.mif $fixeldir/template/fdc
cp $fixeldir/template/fc/directions.mif $fixeldir/template/fdc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fd/PRE.mif $fixeldir/template/fc/PRE.mif -mult $fixeldir/template/fdc/PRE.mif -force
