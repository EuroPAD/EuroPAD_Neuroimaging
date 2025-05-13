#!/bin/bash
#SBATCH --job-name=ss3t_csd
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G             # max memory per node
#SBATCH -t 8:0:0
#SBATCH --output=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/projects/amyloid_bundles/slurm_outputs/%x_%j.out
#SBATCH --partition=luna-short  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000                     # be nice


###
module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

singularity=$1
scratchdir=$2
subject=$3
session=$4
qsirecdir=$5

singularity exec  $singularity ss3t_csd_beta1 $scratchdir/${subject}_${session}/${subject}_${session}_dwi_upsampled.mif ${qsirecdir}/group_average_response_wm.txt  $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_wmfod.mif ${qsirecdir}/group_average_response_gm.txt  $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_gmfod.mif ${qsirecdir}/group_average_response_csf.txt  $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_csffod.mif -mask $scratchdir/${subject}_${session}/${subject}_${session}_mask_upsampled.mif




#### COPY BACK
cp $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_wmfod.mif ${qsirecdir}/$subject/$session/dwi/
cp $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_gmfod.mif ${qsirecdir}/$subject/$session/dwi/
cp $scratchdir/${subject}_${session}/${subject}_${session}_group_average_response_csffod.mif ${qsirecdir}/$subject/$session/dwi/

#### REMOVE
rm -rf $scratchdir/${subject}_${session}/
