##### TBSS for longitudinal timepoint  ###

# after having run the first two steps, we can run the initial steps of the TBSS n longitudinal timepoints, so that the skeleton can be later applied to all timepoints. 

basedir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD
#fadir=${basedir}/derivatives/qsirecon
tbssdir=${basedir}/derivatives/TBSS
xasldir=${basedir}/derivatives/ExploreASL/analysis

mkdir $tbssdir/longitudinal_tbss


for origfile in $(ls $tbssdir/FA/*FA.nii.gz); do 
	
	fafile=$(basename $origfile);

	subname=$(echo $fafile | cut -d "_" -f 1);

	if [[ $(ls -d ${xasldir}/*${subname}* | grep -v _1 | wc -l) -ge 1 ]]; then  ## If they have longitudinal data
		echo $subname; 
		
		for subfold in $(ls -d ${xasldir}/*${subname}* | grep -v _1); do  ## copy data to longitudinal folder 
			nameTP=$(basename $subfold)	
			cp ${subfold}/dwi/DTIfit_FA.nii.gz $tbssdir/longitudinal_tbss/${nameTP}_FA.nii.gz; 
		done
	fi
done



#tbss_1_preproc
cd $tbssdir/longitudinal_tbss

echo "TBSS for FA images"

cm2="tbss_1_preproc *.nii.gz"

echo "tbss_1_preproc *.nii.gz"

$cm2

#tbss_2_reg
  # -T :all images are registrated to FMRIB58_FA standard-space image
  # -t :all images are registrated to your own target image
  # -n :'most representative' image is found, and all images are registrated to this image

cd $tbssdir/longitudinal_tbss

#### WAIT for QC to run this ####
cm3="tbss_2_reg -T"

echo "tbss_2_reg -T"

$cm3

#tbss_3_postreg

cm4="tbss_3_postreg -S"

echo "tbss_3_postreg -S"

$cm4

### Now trick TBSS by putting the baseline skeleton in the longitudinal folder and run step 4
bskel=${tbssdir}/stats/mean_FA_skeleton.nii.gz


cp $bskel $tbssdir/longitudinal_tbss/stats/
threshold=0.2
cm5="tbss_4_prestats $threshold"

echo "tbss_4_prestats $threshold"

$cm5


