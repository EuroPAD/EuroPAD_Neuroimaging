#!/bin/bash
#SBATCH --job-name=dualreg
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G              # max memory per node
#SBATCH -t 36:00:00
#SBATCH --partition=luna-long  # rng-short is default, but use rng-long if time exceeds 7h
#SBATCH --nice=1000

# software
module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."
dualregressionversion=$(dual_regression | grep "dual_regression v" | cut -d " " -f 2)

# directories
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
fmriprepdir=$studydir/derivatives/fmriprep-v23.0.1
DRdir=$studydir/derivatives/dualregression-$dualregressionversion
fmriprep_qc=$fmriprepdir/fmriprep_qc.csv # assuming visual QC has been performed
atlasfile=$studydir/code/multimodal_MRI_processing/atlases/yeo-17-liberal_network_4D_2mm_bin.nii.gz #yeo-17-liberal_network_4D_2mm_bin.nii.gz ## Default is YEO networks
scratchfold=/home/radv/$(whoami)/my-scratch/EuroPAD/Dual_Regression # Derivative folder where to run it if it does not work on local directories

# output directories
mkdir -p $DRdir
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

# run the dual regression
if [[ -d $scratchfold ]]; then
	cd $scratchfold	
	cp -rf $DRdir/design.mat $scratchfold/design.mat
	cp -rf $DRdir/design.con $scratchfold/design.con
	cp -rf $DRdir/fmri_inputs.txt $scratchfold/fmri_inputs.txt
	echo 'Starting the dual regression'
	dual_regression $atlasfile 1 -1 1  $scratchfold `cat $scratchfold/fmri_inputs.txt`

else
	echo "Scratchfolder not found... try creating $scratchfold"
fi

echo "Script finished!"