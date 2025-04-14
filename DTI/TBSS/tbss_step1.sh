basedir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/ # Study dir
fadir=${basedir}/derivatives/qsirecon-v0.19.0 # where the subj folder live
tbssdir=${basedir}/derivatives/TBSS
mode="qsirecon" # exploreASL or qsirecon?


if [[ ! -d $tbssdir ]]; then 
	mkdir $tbssdir; 
else 
	echo "TBSS output dir already exist, probably overwriting results"; 
fi 




#Find FA files 
if [[ $mode == "qsirecon" ]]; then 
	for fafile in $(ls $fadir/sub-*/ses*/dwi/*desc-dti_fa_gqiscalar.nii.gz); do

	 	echo $fafile
		cp $fafile $tbssdir

	done 
elif [[ $mode == "ExploreASL" ]]; then 
	for fafile in $(ls $fadir/*_1/dwi/DTIfit_FA.nii.gz); do

	 	echo $fafile
		sub=$(basename $(dirname $(dirname $fafile)))
		cp $fafile $tbssdir/${sub}_FA.nii.gz

	done 

fi 


#tbss_1_preproc
cd $tbssdir

echo "TBSS for FA images"

cm2="tbss_1_preproc *.nii.gz"

echo "tbss_1_preproc *.nii.gz"

$cm2


echo " First step of TBSS is complete, please QC the FA images before proceeding to tbss_step2.sh " 



