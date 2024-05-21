## Bash script to extract suvr values from atlas-defined ROIs

module load fsl/6.0.7.6

projfold=/data/radv/radG/RAD/share/AMYPAD #amypad folder
raw=/data/radv/radG/RAD/share/AMYPAD/raw/Release/rawdata
id_translation=$projfold/AMYPAD-PNHS_xnat_Keyfile_full.csv # hash table
scratch=/home/radv/$(whoami)/my-scratch
labels=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/AMYPAD/scripts/multimodal_MRI_processing/transforms/Desikan_killiany_MNI152.csv
mkdir -p $scratch/pet_images_reoriented

csv_file=$scratch/suvr_amypad_DK1.csv #create csv file to store values
column_labels="Subject"
for label in `cat $labels | awk -F ',' '{print $1}' | tail -112` ; do
	column_labels+=",Label_${label}"
done

echo $column_labels > $csv_file

for subjectname in `ls -d $projfold/derivatives/fmriprep-v23.0.1/sub-* | grep -v html | head -400` ; do # first 400

   	bidsname="`basename $subjectname`";
	amypad_id="`echo $bidsname | cut -d '-' -f 2`"
	printf "Extracting SUVr for subject $bidsname...\n"
	
	if [ `ls -d $subjectname/ses-* | wc -l` -gt 1 ]; then #fmriprep saves differently depending on whether there's one or more sessions
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`";
			atlas_spaceT1=$projfold/derivatives/fmriprep-v23.0.1/$bidsname/anat/${bidsname}_${sesname}_space-T1w_aparcaseg_1mm.nii.gz
			pet_session="`grep "$amypad_id" "$id_translation" | awk -F',' -v sesname="$sesname" '$8 ~ sesname {print $9}'`"
			pet_image=$projfold/derivatives/ixico-elastix-cb-suvr-mario/$bidsname/$pet_session/pet/*space-T1w_desc-suvrcereb_pet.nii.gz
			if [ -f $pet_image ]; then #Continue only if pet_image exists

				reoriented_pet_image=$projfold/derivatives/ixico-elastix-cb-suvr-mario/$bidsname/$pet_session/pet/${bidsname}_${sesname}_space-T1w_desc-suvrcereb_pet_reoriented2std.nii.gz
			
				if [ ! -f $reoriented_pet_image ]; then #Create reoriented_pet_image if it does not exist
					printf "	Reorienting PET...\n"
					fslreorient2std $pet_image $reoriented_pet_image
				fi

				declare -a pet_means=() #create array to store info
				mkdir -p $scratch/masks_DK/${bidsname}/${sesname}

				for label in `cat $labels | awk -F ',' '{print $1}' | tail -112`; do
 					mask_dir="$scratch/masks_DK/${bidsname}/${sesname}/roimask_${label}"
   					if [ ! -d "$mask_dir" ]; then
		    				mkdir -p "$mask_dir"
		     				fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label}; # take one roi from atlas
		        		fi 

					label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -M) #extract mean value from the non-zero voxels of each label
					pet_means+=($label_pet_values) #append suvr value to the array
 				done
				string_of_values=${pet_means[@]}
				echo "${bidsname}_${sesname},${string_of_values// /,}" >> $csv_file
			fi
		done
	else
		for session in `ls -d ${subjectname}/ses-*`; do
			sesname="`basename $session`" ;
			atlas_spaceT1=$projfold/derivatives/fmriprep-v23.0.1/$bidsname/$sesname/anat/${bidsname}_${sesname}_space-T1w_aparcaseg_1mm.nii.gz
			pet_session="`grep $amypad_id $id_translation | grep $sesname | awk -F',' '{print $9}'`"
			pet_image=$projfold/derivatives/ixico-elastix-cb-suvr-mario/$bidsname/$pet_session/pet/*space-T1w_desc-suvrcereb_pet.nii.gz
			if [ -f $pet_image ]; then #Continue only if pet_image exists

				reoriented_pet_image=$projfold/derivatives/ixico-elastix-cb-suvr-mario/$bidsname/$pet_session/pet/${bidsname}_${sesname}_space-T1w_desc-suvrcereb_pet_reoriented2std.nii.gz
			
				if [ ! -f $reoriented_pet_image ]; then #Create reoriented_pet_image if it does not exist
					printf "	Reorienting PET...\n"
					fslreorient2std $pet_image $reoriented_pet_image
				fi
			
				declare -a pet_means=() #create array to store info
				mkdir -p $scratch/masks_DK/${bidsname}/${sesname}

				for label in `cat $labels | awk -F ',' '{print $1}' | tail -112`; do
				mask_dir="$scratch/masks_DK/${bidsname}/${sesname}/roimask_${label}"
   				if [ ! -d "$mask_dir" ]; then
					mkdir -p "$mask_dir"
		     			fslmaths $atlas_spaceT1 -thr $label -uthr $label -bin $mask_dir/roimask_${label}; # take one roi from atlas
		       		fi 
					label_pet_values=$(fslstats $reoriented_pet_image -k $mask_dir/roimask_${label} -M) #extract mean value from the non-zero voxels of each label
					pet_means+=($label_pet_values) #append suvr value to the array
 				done
				string_of_values=${pet_means[@]}
				echo "${bidsname}_${sesname},${string_of_values// /,}" >> $csv_file
			else
				printf "   no PET scan found...\n"
			fi
		done
	fi
done

printf "Script finished!\n\n"
