#!/bin/bash
#SBATCH --job-name=suvr
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=3
#SBATCH --mem=8G             # max memory per node
# Request 7 hours run time
#SBATCH -t 7-00:00:0
#SBATCH --partition=luna-long  # luna-short is default, but use luna-long if time exceeds 7h
#SBATCH --nice=1000

## BASH script to extract suvr values and voxel count from atlas-defined ROIs

# BASH Dependencies:
module load fsl/6.0.7.6

projfold=/data/radv/radG/RAD/share/AMYPAD #amypad folder
num_labels=100 #define the number of atlas labels
raw=/data/radv/radG/RAD/share/AMYPAD/raw/Release/rawdata
id_translation=$projfold/AMYPAD-PNHS_xnat_Keyfile_full.csv # hash table
scratch=/home/radv/$(whoami)/my-scratch
mkdir -p $scratch/pet_images_reoriented
mkdir -p $scratch/atlas_images_reoriented

csv_file=$scratch/suvr_amypad_yeo17_homotopic.csv #create csv file to store values
csv_file_voxel=$scratch/voxel_count_amypad_yeo17_homotopic.csv
#column_labels="Subject"
#for ((i=1; i<num_labels+1; i++)); do
#	column_labels+=",Label_${i}"
#done
#echo $column_labels > $csv_file
#echo $column_labels > $csv_file_voxel

counter=0
limit=3000  # Set your desired limit here

for subjectname in `ls -d $projfold/derivatives/fmriprep-v23.0.1/sub-* | grep -v html`; do

if [ $counter -lt $limit ]; then
   	bidsname="`basename $subjectname`";
	amypad_id="`echo $bidsname | cut -d '-' -f 2`"
	printf "Extracting SUVr for subject $bidsname....\n"
	
	if [ `ls -d $subjectname/ses-* | wc -l` -gt 1 ]; then #fmriprep saves differently depending on whether there's one or more sessions
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`";
			atlas_spaceT1=$projfold/derivatives/fmriprep-v23.0.1/$bidsname/anat/${bidsname}_${sesname}_space-T1w_100Parcels_Yeo2011_17Networks_1mm.nii.gz
			pet_session="`grep "$amypad_id" "$id_translation" | awk -F',' -v sesname="$sesname" '$8 ~ sesname {print $9}'`"
			pet_image=$projfold/derivatives/ixico-elastix-cbgrey-suvr/$bidsname/$pet_session/pet/*space-T1w_desc-suvrcerebgrey_pet.nii.gz
			pattern=${bidsname}_${sesname}
			string=$(grep -e ${pattern} $csv_file | awk -F, '{print $1}')
			if [[ "$string" != *"${bidsname}_${sesname}"* ]]; then 

				if [ -f $pet_image ]; then #Continue only if pet_image exists 
					reoriented_pet_image=$scratch/pet_images_reoriented/${bidsname}_${sesname}_space-T1w_desc-suvrcerebgrey_pet_reoriented2std.nii.gz
			
					if [ ! -f $reoriented_pet_image ]; then #Create reoriented_pet_image if it does not exist
						fslreorient2std $pet_image $scratch/pet_images_reoriented/${bidsname}_${sesname}_space-T1w_desc-suvrcerebgrey_pet_reoriented2std.nii.gz
					fi

					declare -a pet_means=() #create array to store info
					
					#extract suvr
					for label in $(seq 1 $num_labels); do

					mask_dir="$scratch/masks_homotopic/${bidsname}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label};
		        		fi 	
						label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -M) #extract mean value from the non-zero voxels of each label
						pet_means+=($label_pet_values) #append suvr value to the array
 					done
					echo "${bidsname}_${sesname},${pet_means[@]}" >> $csv_file
					
					declare -a pet_means=() #create array to store info
					#extract voxel count
					for label in $(seq 1 $num_labels); do
		    			mask_dir="$scratch/masks_homotopic/${bidsname}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label};
		        		fi 

						label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -V | awk '{print $1}') #extract mean value from the non-zero voxels of each label
						pet_means+=($label_pet_values) #append voxel count to the array
 					done
					echo "${bidsname}_${sesname},${pet_means[@]}" >> $csv_file_voxel
				fi
			else
				echo "voxel count for $bidsname has been already extracted"
			fi
		done
	else
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`" ;
			atlas_spaceT1=$projfold/derivatives/fmriprep-v23.0.1/$bidsname/$sesname/anat/${bidsname}_${sesname}_space-T1w_100Parcels_Yeo2011_17Networks_1mm.nii.gz
			pet_session="`grep $amypad_id $id_translation | grep $sesname | awk -F',' '{print $9}'`"
			pet_image=$projfold/derivatives/ixico-elastix-cbgrey-suvr/$bidsname/$pet_session/pet/*space-T1w_desc-suvrcerebgrey_pet.nii.gz
			pattern=${bidsname}_${sesname}
			string=$(grep -e ${pattern} $csv_file | awk -F, '{print $1}')
			if [[ "$string" != *"${bidsname}_${sesname}"* ]]; then 
				
				if [ -f $pet_image ]; then #Continue only if pet_image exists

					reoriented_pet_image=${scratch}/pet_images_reoriented/${bidsname}_${sesname}_space-T1w_desc-suvrcerebgrey_pet_reoriented2std.nii.gz
			
					if [ ! -f $reoriented_pet_image ]; then #Create reoriented_pet_image if it does not exist
						fslreorient2std $pet_image $scratch/pet_images_reoriented/${bidsname}_${sesname}_space-T1w_desc-suvrcerebgrey_pet_reoriented2std.nii.gz
					fi
			
					declare -a pet_means=() #create array to store info
				
					#extract suvr
					for label in $(seq 1 $num_labels); do
		    			mask_dir="$scratch/masks_homotopic/${bidsname}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label};
		        		fi 

						label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -M) #extract mean value from the non-zero voxels of each label
						pet_means+=($label_pet_values) #append suvr value to the array
 					done
					echo "${bidsname}_${sesname},${pet_means[@]}" >> $csv_file
					
					declare -a pet_means=() #create array to store info
					#extract voxel count
					for label in $(seq 1 $num_labels); do
		    			mask_dir="$scratch/masks_homotopic/${bidsname}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label};
		        		fi 

						label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -V | awk '{print $1}') #extract mean value from the non-zero voxels of each label
						pet_means+=($label_pet_values) #append suvr value to the array
 					done
					echo "${bidsname}_${sesname},${pet_means[@]}" >> $csv_file_voxel
				fi
			else
				echo "voxel count for $bidsname has been already extracted"
			fi
		done
	fi
       
        ((counter++))  # Increment the counter
else
	echo "Reached the limit of $limit subjects. Stopping loop." 
	break
fi
	
#rm -rf $scratch/masks/${bidsname}/
done
printf "Script finished!\n\n"
