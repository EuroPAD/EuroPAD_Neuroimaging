#!/bin/bash
#SBATCH --job-name=idp_extraction
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G             # max memory per node
# Request 24 hours run time
#SBATCH -t 24:00:00
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

# BASH script to extract mean values from atlas-defined ROIs

# BASH Dependencies:
module load fsl/6.0.7.6

codedir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/general # location of script
studydir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD # location of BIDS directory
atlasname=$codedir/../atlases/Desikan_killiany_MNI152.csv # name of atlas labeling file
labels=$codedir/../atlases/Desikan_killiany_MNI152.csv

num_labels=$(($(cat $atlasname | wc -l) - 1)) #define the number of atlas labels

raw=$studydir/rawdata
fmriprep_store4ever=/data/radv/radG/RAD/share/AMYPAD/derivatives/fmriprep-v23.0.1
scratch=/home/radv/$(whoami)/my-scratch
mkdir -p $scratch/pet_images_reoriented
mkdir -p $scratch/atlas_images_reoriented

csv_file=$scratch/suvr_2Desikan_killiany_MNI152.csv # csv file to store mean values

column_labels="Subject"
for label in `cat $labels | awk -F ',' '{print $1}' | tail -112` ; do
	column_labels+=",Label_${label}"
done

echo $column_labels > $csv_file
echo $column_labels > $csv_file_voxel

counter=0
limit=3000  # Set your desired iteration limit here

files=($(ls -d $fmriprep_store4ever/sub-* | grep -v html))
for subjectname in `echo "${files[@]:400:800}"`; do

if [ $counter -lt $limit ]; then
	bidsname_old="`basename $subjectname`";
   	bidsname="`basename $subjectname | sed 's/sub-/sub-AMYPAD/'`";
	printf "Extracting SUVr for subject $bidsname....\n"

	for session in `ls -d ${subjectname}/ses-*`; do
		sesname="`basename $session`";
		atlas_spaceT1=$fmriprep_store4ever/$bidsname_old/anat/${bidsname_old}_${sesname}_space-T1w_aparcaseg_1mm.nii.gz.nii.gz
		pet_image=$studydir/derivatives/suvr-v24.02.07/$bidsname/${sesname}/pet/*space-T1w_desc-suvrcerebgrey_pet.nii.gz
		pattern=${bidsname}_${sesname}
		string=$(grep -e ${pattern} $csv_file | awk -F, '{print $1}')
		if [[ "$string" != *"${bidsname}_${sesname}"* ]]; then 

			if [ -f $pet_image ]; then #Continue only if pet_image exists 
				reoriented_pet_image=$studydir/derivatives/suvr-v24.02.07/$bidsname/${sesname}/pet/${bidsname}_${sesname}_space-T1w_desc-suvrcereb_pet_reoriented2std.nii.gz
			
				if [ ! -f $reoriented_pet_image ]; then #Create reoriented_pet_image if it does not exist
					fslreorient2std $pet_image $reoriented_pet_image
				fi

				declare -a pet_means=() #create array to store info
					
				#extract suvr
				for label in `cat $labels | awk -F ',' '{print $1}' | tail -112` ; do

					mask_dir="$scratch/masks_DK/${bidsname_old}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label};
		        		fi 	
					label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -M) #extract mean value from the non-zero voxels of each label
					pet_means+=($label_pet_values) #append suvr value to the array
 				done
				string_of_values=${pet_means[@]}
				echo "${bidsname}_${sesname},${string_of_values// /,}" >> $csv_file
					
				declare -a pet_means=() #create array to store info

				fi
		else
			echo "voxel count for $bidsname has been already extracted"
		fi
	done
       
        ((counter++))  # Increment the counter
else
	echo "Reached the limit of $limit subjects. Stopping loop." 
	break
fi
	
#rm -rf $scratch/masks/${bidsname}/
done
printf "Script finished!\n\n"
