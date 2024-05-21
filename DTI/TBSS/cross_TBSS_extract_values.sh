## Bash script to extract mean and other values from skeletonised images (output of tbss pipeline)

longitudinal=0 ## Also extract from longitudinal run ? Check tbss_long.sh 

projfold="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD"
tbssfold="/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/Twins_DTI_20200611/DTI_FINALTBSSDATA"   # "$projfold/derivatives/TBSS" # Changed for TWINS
statfold="$tbssfold/stats"
mask="$statfold/mean_FA_skeleton_mask.nii.gz"
subregexp=EMI


atlas="$projfold/scripts/multimodal_MRI_processing/atlases/JHU-ICBM-labels-1mm.nii.gz"

# define scalars that are available for extraction
scalars="MD"  # "FA MD"

cd $tbssfold
# Loop over scalars
for SC in $scalars; do 

	echo " starting extraction of ${SC} global and regional values" ;
	
	allim="$statfold/all_${SC}_skeletonised.nii.gz"
	  
	  # GLOBAL EXTRACTION --> Mean scalar in WM skeleton
	echo "Computing global ${SC} value in skeleton..."
	  
	cd $tbssfold/FA # We always have to do this on FA 
	ls -d  *$subregexp*  | awk -F '_' '{print $1 "," $2}' | sort -u > $statfold/subvisits.txt
	cd $tbssfold	
	fslstats -t $allim -k $mask -M > $statfold/meants${SC}.txt
	  
	paste -d,  $statfold/subvisits.txt  $statfold/meants${SC}.txt > $statfold/tbss_regional_${SC}.txt
	echo "subject, MRI_visit, mean${SC}" > $statfold/hdr_${SC}.txt

	# REGIONAL EXTRACTION --> Mean scalar in JHU atlas regions
	echo "Computing regional ${SC} values in atlas regions..."
	mkdir $statfold/regional_values

	# iterate regions
	for roinum in {1..48}; do # 48 labels in atlas
	    echo "JHU atlas roi ${roinum}"

	    # Create skeletonised regional mask if it does not exist
	    if [[ ! -f $statfold/regional_values/roimask${roinum}_skel.nii.gz ]]; then 
	      fslmaths $atlas -thr $roinum -uthr $roinum -bin $statfold/regional_values/roimask${roinum}; # take one roi from atlas

	      fslmaths $statfold/regional_values/roimask${roinum} -mas $mask -bin $statfold/regional_values/roimask${roinum}_skel;   # take only where our skeleton is
	    fi 

	    # Regional scalar
	    fslstats -t $allim -k $statfold/regional_values/roimask${roinum}_skel -M > $statfold/regional_values/meants_${SC}_roi${roinum}.txt #extract mean per volume (subject)

	    # store results
	    paste -d, $statfold/tbss_regional_${SC}.txt $statfold/regional_values/meants_${SC}_roi${roinum}.txt > $statfold/tbss_regional_${SC}_new.txt
	    rm $statfold/tbss_regional_${SC}.txt
	    mv $statfold/tbss_regional_${SC}_new.txt $statfold/tbss_regional_${SC}.txt

	    #update csv header
	    echo "`cat $statfold/hdr_${SC}.txt`,JHU_${SC}_${roinum}" > $statfold/hdr_${SC}.txt

  	done

  # create csv 
  #FA
  	cat $statfold/hdr_${SC}.txt  > $statfold/tbss_regional_${SC}.csv
  	cat $statfold/tbss_regional_${SC}.txt >> $statfold/tbss_regional_${SC}.csv

  # remove unnecessary
	rm $statfold/tbss_regional_${SC}.txt
	rm $statfold/regional_values/meants_${SC}_*

done



### Longitudinal extraction
if [[ $longitudinal -eq 1 ]]; then   ## Use the skeleton to extract regional values from longitudinal run 
	longdir=$tbssfold/longitudinal_tbss; 
	for SC in $scalars; do 

		echo " starting longitudinal extraction of ${SC} global and regional values" ;

		allim="$longdir/stats/all_${SC}_skeletonised.nii.gz"; 

		cd $longdir/FA # always do this on FA (because it is QCed)
		ls -d  *$subregexp*  | awk -F '_' '{print $1 "," $2}' | sort -u > $longdir/stats/subvisits.txt
		cd $longdir

		fslstats -t $allim -k $mask -M >$longdir/stats/meants${SC}.txt  # allim is the longitudinal, mask is the same as baseline; WE HAVE TO USE FSLSTATS OTHERWISE WE INCLUDE ZERO VALUES (AS THIS IS NOT THEIR SKELETON)
		
		paste -d,  $longdir/stats/subvisits.txt  $longdir/stats/meants${SC}.txt > $longdir/stats/tbss_regional_${SC}.txt
		echo "subject, MRI_visit, mean${SC}" > $longdir/stats/hdr_${SC}.txt

		# REGIONAL EXTRACTION --> Mean scalar in JHU atlas regions
		echo "Computing regional ${SC} values in atlas regions..."
		mkdir $longdir/stats/regional_values

		# iterate regions
		for roinum in {1..48}; do # 48 labels in atlas
		    echo "JHU atlas roi ${roinum}"

		    # Create skeletonised regional mask if it does not exist
		    if [[ ! -f $longdir/stats/regional_values/roimask${roinum}_skel.nii.gz ]]; then 
		      fslmaths $atlas -thr $roinum -uthr $roinum -bin $longdir/stats/regional_values/roimask${roinum}; # take one roi from atlas

		      fslmaths $longdir/stats/regional_values/roimask${roinum} -mas $mask -bin $longdir/stats/regional_values/roimask${roinum}_skel;   # take only where our skeleton is
		    fi 

		    # Regional scalar
		    fslstats -t $allim -k $longdir/stats/regional_values/roimask${roinum}_skel -M > $longdir/stats/regional_values/meants_${SC}_roi${roinum}.txt #extract mean per volume (subject)

		    # store results
		    paste -d, $longdir/stats/tbss_regional_${SC}.txt $longdir/stats/regional_values/meants_${SC}_roi${roinum}.txt > $longdir/stats/tbss_regional_${SC}_new.txt
		    rm $longdir/stats/tbss_regional_${SC}.txt
		    mv $longdir/stats/tbss_regional_${SC}_new.txt $longdir/stats/tbss_regional_${SC}.txt

		    #update csv header
		    echo "`cat $longdir/stats/hdr_${SC}.txt`,JHU_${SC}_${roinum}" > $longdir/stats/hdr_${SC}.txt

	  	done
			

	  # create csv 
	  #FA
	  	cat $longdir/stats/hdr_${SC}.txt  > $longdir/stats/tbss_regional_${SC}.csv
	  	cat $longdir/stats/tbss_regional_${SC}.txt >> $longdir/stats/tbss_regional_${SC}.csv

	  # remove unnecessary
		rm $longdir/stats/tbss_regional_${SC}.txt
		rm $longdir/stats/regional_values/meants_${SC}_*


	# Merge with baseline 
	cp $statfold/tbss_regional_${SC}.csv $longdir/stats/allvisits_tbss_regional_${SC}.csv

	cat $longdir/stats/tbss_regional_${SC}.csv >> $longdir/stats/allvisits_tbss_regional_${SC}.csv

done
fi 
