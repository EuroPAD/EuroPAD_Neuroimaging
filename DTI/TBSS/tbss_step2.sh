##### TBSS after QC ###

# after having run the first step, you should go through the index.html file created and check whether the images are good or have artefacts/other problems. 
#save the IDs that you wish to exclude from the analyiss in "QC_excluded.txt"
basedir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/
#fadir=${basedir}/derivatives/qsirecon
tbssdir=${basedir}/derivatives/TBSS
MD=0

# for now we are not being very strict, lets evaluate what is the effect on the final skeleton
while read excl; do 

	if [[ `ls $tbssdir/FA/*${excl}* | wc -l` -gt 1 ]]; then  # files need to be cleaned 
		rm  `ls $tbssdir/FA/*${excl}*`; 
	fi


done < QC_excluded.txt


#tbss_2_reg
  # -T :all images are registrated to FMRIB58_FA standard-space image
  # -t :all images are registrated to your own target image
  # -n :'most representative' image is found, and all images are registrated to this image

cd $tbssdir

#### WAIT for QC to run this ####
cm3="tbss_2_reg -T"

echo "tbss_2_reg -T"

$cm3

#tbss_3_postreg

cm4="tbss_3_postreg -S"

echo "tbss_3_postreg -S"

$cm4

#tbss_4_prestats

threshold=0.2
cm5="tbss_4_prestats $threshold"

echo "tbss_4_prestats $threshold"

$cm5


#TBSS_non_FA

#if [[ $MD -eq 1 ]]; then 
	
#	mkdir ${tbssdir}/MD;
#	cd ${tbssdir}/MD/;	
#	# first copy the imaged and give the right name 
#	for mdfile in `ls $fadir/sub-*/ses*/dwi/*desc-md_gqiscalar.nii.gz`; do 
#		cp  $mdfile ${tbssdir}/MD/; 
#		flname=`basename $mdfile`
#		mv $flname ${flname//md_gqiscalar.nii.gz/fa1_gqiscalar.nii.gz}
#	done
#
#fi 

#cd $tbssdir	
#cm6="tbss_non_FA MD"

#echo "tbss_non_FA MD"

#$cm6
