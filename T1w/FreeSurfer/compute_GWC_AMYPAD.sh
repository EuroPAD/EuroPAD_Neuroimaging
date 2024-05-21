#!/bin/bash

module load FreeSurfer
export SUBJECTS_DIR=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer # FreeSurfer directory
sub_dir=/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer/
scripts_dir=/data/radv/radG/RAD/share/AMYPAD/scripts/

cd $SUBJECTS_DIR

for sub in `ls -d sub*_ses-*`; do
	pctsurfcon --s "$sub" --gm-proj-frac 0.35 --b w-g.pct --nocleanup
done

cd $scripts_dir
