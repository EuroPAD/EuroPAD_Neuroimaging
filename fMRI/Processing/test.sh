studydir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/AMYPAD/ALFA
ORIG_BIDS_DIR=$studydir/raw

n=1
for subjectname in `ls -d ${ORIG_BIDS_DIR}/sub-*`; do
	if [ $n == 1 ]; then
		printf "Processing $subjectname\n\n"
	else 
		printf "Not processing $subjectname\n\n"
	
	fi

	n=$n+1
done

echo "Script finished."
