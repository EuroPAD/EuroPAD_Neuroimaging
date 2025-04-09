#!/bin/bash

# Modules
module load fsl
fslversion=$(fslversion | tail -1 | cut -d " " -f 2)
echo "Using FSL version $fslversion..."

# Variables
melodic=$1
atlas2=$2
atlas2_name=$3
output=$4

echo "melodic,$atlas2_name,fslcc" > $output

fslcc -t 0 $melodic $atlas2 | tr -s " " | sed "s/ /,/g" | sed "s/,//" >> $output

echo "Script finished!"
