#!/bin/bash

# how to make a (rotating) brain GIF using FSL; e.g. for presentations or QC; single file example
# fsleyes render "scene" can be ( ortho lightbox 3d ); 3d creates the 3d brain which can be rotated with --cameraRotation x y z

module load fsl

mkdir gif

# file can be a variable from a for loop for whole dataset
file=sub-EPAD04024628_ses-01_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
num_volumes=$(fslnvols sub-EPAD04024628_ses-01_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz) # for 4D files; otherwise just give integer number for number of images
output_gif=gif/animated_brain.gif

for ((i=0; i<$num_volumes; i++)); do # for each frame
	output_frame=$(printf "gif/frame_%04d.png" $i);
	fsleyes render -of $output_frame --scene 3d --displaySpace world --cameraRotation $i 0 0 --zoom 125.0 sub-EPAD04024628_ses-01_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz --cmap fsleyes_hsv --negativeCmap greyscale  --clippingRange 500001.0 3935477.8475 --volume $i; 
done

# Convert the created frames into a GIF
convert -delay 5 -loop 0 gif/frame_*.png $output_gif
