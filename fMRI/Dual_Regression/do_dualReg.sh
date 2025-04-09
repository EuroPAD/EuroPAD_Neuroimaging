#!/bin/bash
#SBATCH --job-name=dualreg
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G              # max memory per node
#SBATCH -t 36:00:00
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000

#FSL
module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."
dualregressionversion=$(dual_regression | grep "dual_regression v" | cut -d " " -f 2)

BIDS_DIR=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
derivativesdir=$BIDS_DIR/derivatives
fmriprepdir=$derivativesdir/fmriprep-v23.0.1
fmriprep_qc=$fmriprepdir/fmriprep_qc.csv
DRdir=$derivativesdir/dualregression-$dualregressionversion
atlasfile=$BIDS_DIR/code/multimodal_MRI_processing/atlases/yeo-17-liberal_network_4D_2mm_bin.nii.gz #yeo-17-liberal_network_4D_2mm_bin.nii.gz ## Default is YEO networks
scratchfold=/home/radv/$(whoami)/my-scratch/EuroPAD/Dual_Regression # Derivative folder where to run it if it does not work on local directories

#make outputdirectory
mkdir -p $DRdir; 
mkdir -p $scratchfold

# select all inputs 
ls $fmriprepdir/sub*/ses*/func/*MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold_mask_4smoothed.nii.gz >  $DRdir/fmri_inputs.txt

# filter inputs through QC file
for file in `cat $DRdir/fmri_inputs.txt`; do
	subses=$(echo $file | cut -d "/" -f 13,14 | sed "s./._.");

	if [ $(grep -c $subses $fmriprep_qc) -eq 1 ]; then # if this file is mentioned in the QC fail list
		echo "$subses: EXCLUDED...";
	else
		echo "$subses: INCLUDED...";
		echo $file >> $DRdir/fmri_inputs_filtered.txt;
	fi
done

# rename files so that fmri_inputs.txt is final
mv $DRdir/fmri_inputs.txt $DRdir/fmri_inputs_unfiltered.txt
mv $DRdir/fmri_inputs_filtered.txt $DRdir/fmri_inputs.txt

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
	dual_regression $atlasfile 1 -1 1  $scratchfold `cat $scratchfold/fmri_inputs.txt`
	#dual_regression $atlasfile 1 $scratchfold/design.mat $scratchfold/design.con 0 $scratchfold `cat $scratchfold/fmri_inputs.txt`
else 
	dual_regression $atlasfile 1 -1 1  $scratchfold `cat $scratchfold/fmri_inputs.txt`
	#dual_regression $atlasfile 1 $DRdir/design.mat $DRdir/design.con 0 $DRdir `cat $DRdir/fmri_inputs.txt`; 
fi
