#!/bin/bash
#SBATCH --job-name=tractography
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=20G             # max memory per node
# Request 7 hours run time
#SBATCH -t 2-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1			# be nice

qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario
#QSIPREP=/home/radv/mtranfa/qsiprep-0.19.0.sif

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

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
