#!bin/bash

# define directories
studydir=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD
bamos_cross=$studydir/derivatives/bamos_cross

# initiate group file
cat $bamos_cross/Separation_sub* | head -1 > $bamos_cross/Separation_group.csv

# concatenate subjects onto group file
for subses in `ls $bamos_cross/Separation_sub*.csv`; do
	cat $subses | tail -1 >> $bamos_cross/Separation_group.csv
done
