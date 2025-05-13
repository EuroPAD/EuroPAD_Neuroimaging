#!/bin/bash
#SBATCH --job-name=fmri_qc
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G              	# max memory per node
#SBATCH -t 72:00:00				# hh:mm:ss
#SBATCH --partition=luna-long  	# luna-short is default, use luna-long if time is expected to exceed 7h

# fsleyes render "scene" can be ( ortho lightbox 3d ); 3d creates the 3d brain which can be rotated with --cameraRotation x y z

# dependencies
module load fsl

# variables
studydir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
fmriprepdir=$studydir/derivatives/fmriprep-v23.0.1
postprocess_file=task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz

mkdir -p "$fmriprepdir/qc_gifs"

for sub in "$fmriprepdir"/sub-*; do
	[[ -d "$sub" && "$sub" != *.html ]] || continue
	subject=$(basename "$sub")
	for ses in "$sub"/ses*; do
		[[ -d "$ses" ]] || continue
		session=$(basename "$ses")
		if [ -f "$fmriprepdir/qc_gifs/${subject}_${session}_sagittal.gif" ]; then # skip QC generation if already exists
			printf "\nSkipping QC for %s_%s...\n" "$subject" "$session"
		else
			printf "\nCreating QC for %s_%s...\n" "$subject" "$session"
			fmrifile="$ses/func/${subject}_${session}_${postprocess_file}"
			num_volumes=$(fslnvols "$fmrifile")
			increment=$((num_volumes / 10))
		
			for i in $(seq 0 10); do # for 10 frames;
				printf "  Rendering %s/10...\r" "$i"
				j=$((i * increment))
				output_frame=$(printf "%s/qc_gifs/sagittal_frame_%04d.png" "$fmriprepdir" "$i") # render 10 sagittal lightboxes
				fsleyes render -of "$output_frame" --scene lightbox --zrange 0.0 1.0 --zaxis 0 --hideCursor "$fmrifile" --volume "$j"
				output_frame=$(printf "%s/qc_gifs/axial_frame_%04d.png" "$fmriprepdir" "$i") # & render 10 axial lightboxes
				fsleyes render -of "$output_frame" --scene lightbox --zrange 0.0 1.0 --zaxis 2 --hideCursor "$fmrifile" --volume "$j"
			done

			# concatenate the lightboxes into .gif files
			printf "\n  Concatenating frames...\n"
			convert -delay 5 -loop 0 "$fmriprepdir/qc_gifs/sagittal_frame_*.png" "$fmriprepdir/qc_gifs/${subject}_${session}_sagittal.gif"
			convert -delay 5 -loop 0 "$fmriprepdir/qc_gifs/axial_frame_*.png" "$fmriprepdir/qc_gifs/${subject}_${session}_axial.gif"
		fi
	done
done

printf "Script finished!\n\n"
