#!bin/bash

# BaMoS directory:
bamos_cross=/home/radv/$USER/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/bamos_cross

# initiate group file:
cat $bamos_cross/Separation_sub* | head -1 > $bamos_cross/Separation_group.csv

# concatenate subjects onto gruop file:
for subses in `ls $bamos_cross/Separation_sub*.csv`; do
	cat $subses | tail -1 >> $bamos_cross/Separation_group.csv
done
