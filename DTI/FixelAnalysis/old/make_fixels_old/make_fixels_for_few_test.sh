#!/bin/bash
#SBATCH --job-name=fixel
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=80G             # max memory per node
# Request 7 hours run time
#SBATCH -t 3-00:0:0
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000			# be nice

qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

### Include all subjects from now on
# Segment subjects' FOD images, to estimate fixels and apparent fibers density
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented
for_each $fixeldir/subjects/* : fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented -afd fd.mif 

# Now reorient the fixels bsed on local transformation taken from previous warps
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_desc-wmFixels
for_each $fixeldir/subjects/* : fixelreorient IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented IN/ses-01/dwi/NAME_to_template.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels

# match fixels from each individual to te template ones
rm $fixeldir/template/fd/index.mif
rm $fixeldir/template/fd/directions.mif
for_each $fixeldir/subjects/* : fixelcorrespondence IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels/fd.mif $fixeldir/template/fixel_mask $fixeldir/template/fd PRE.mif -force

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

# run tractography on the template 
cd $fixeldir/template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 fod_template.mif -seed_image group_mask_intersection.mif -mask group_mask_intersection.mif -select 20000000 -cutoff 0.1 tracks_20_million.tck -force

tcksift tracks_20_million.tck fod_template.mif tracks_2_million_sift.tck -term_number 2000000 -force # filter

# Fixel Connectivity
fixelconnectivity fixel_mask/ tracks_2_million_sift.tck matrix/ -force

# Fixel filtering (smoothing)
rm $fixeldir/template/fd_smooth/index.mif
rm $fixeldir/template/fd_smooth/directions.mif
fixelfilter fd smooth fd_smooth -matrix matrix/ -force

rm $fixeldir/template/log_fc_smooth/index.mif
rm $fixeldir/template/log_fc_smooth/directions.mif
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/ -force

rm $fixeldir/template/fdc_smooth/index.mif
rm $fixeldir/template/fdc_smooth/directions.mif
fixelfilter fdc smooth fdc_smooth -matrix matrix/ -force

# Create files.txt for statistical analysis
rm ${fixeldir}/template/files.txt
for sub in `ls -d ${fixeldir}/template/fd_smooth/sub*`; do
subname=`basename $sub`; 
	echo $subname >> ${fixeldir}/template/files.txt;
done

