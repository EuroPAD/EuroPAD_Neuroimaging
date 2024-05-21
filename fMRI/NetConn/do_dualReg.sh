#!/bin/bash
#SBATCH --job-name=dualreg
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=50000              # max memory per node
#SBATCH -t 36:00:00
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=2000

BIDS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD
derivativesdir=$BIDS_DIR/derivatives
fmriprepdir=$derivativesdir/fmriprep
DRdir=$derivativesdir/DualRegression
atlasfile=$BIDS_DIR/scripts/multimodal_MRI_processing/atlases/yeo-17-liberal_network_4D_2mm_bin.nii.gz #yeo-17-liberal_network_4D_2mm_bin.nii.gz ## Default is YEO networks
scratchfold=/home/radv/llorenzini/my-scratch/EPAD/Dual_Regression # Derivative folder where to run it if it does not work on local directories 

#make outputdirectory
if [[ ! -d $DRdir ]]; then 
	mkdir $DRdir; 
	mkdir -p $scratchfold
else
echo "Dual Regression Output Directory is already existing, probably overwriting results" 

fi 

#selct inputs 
ls $fmriprepdir/sub*/ses*/func/*MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask.nii.gz >  $DRdir/fmri_inputs.txt  

# Create Design Matrix
echo "creating design matrix for `cat $DRdir/fmri_inputs.txt | wc -l` files"

sleep 2

while read file; do 
echo "1"
done < $DRdir/fmri_inputs.txt > $DRdir/design.txt

sleep 2



## Create and convert con and mat files 
echo "converting txt to mat"

Text2Vest $DRdir/design.txt $DRdir/design.mat

cat $DRdir/design.txt | head -1 > $DRdir/contrast.txt

Text2Vest $DRdir/contrast.txt $DRdir/design.con


# run the dual regression
cd $scratchfold	
if [[ -d $scratchfold ]]; then

	cp -rf $DRdir/design.mat $scratchfold/design.mat; 
	cp -rf $DRdir/design.con $scratchfold/design.con; 
	cp -rf $DRdir/fmri_inputs.txt $scratchfold/fmri_inputs.txt; 
	echo 'Starting the dual regression';
	dual_regression $atlasfile 1 $scratchfold/design.mat $scratchfold/design.con 0 $scratchfold `cat $scratchfold/fmri_inputs.txt`
else 

	dual_regression $atlasfile 1 $DRdir/design.mat $DRdir/design.con 0 $DRdir `cat $DRdir/fmri_inputs.txt`; 
fi




