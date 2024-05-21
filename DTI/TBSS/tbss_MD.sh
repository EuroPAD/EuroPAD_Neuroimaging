basedir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD # Study dir
fadir=${basedir}/derivatives/ExploreASL/analysis # where the subj folder live
tbssdir=${basedir}/derivatives/TBSS
mode="ExploreASL" # exploreASL or qsirecon?
baseline=0 # run longitudinal ? 
longitudinal=1 # run longitudinal ? 

## Baseline run 
if [[ $baseline -eq 1 ]]; then 
	for mdfile in $(ls $fadir/*_1/dwi/DTIfit_MD.nii.gz); do 

		echo $mdfile; 
		sub=$(basename $(dirname $(dirname $mdfile)))
		cp $mdfile $tbssdir/MD/${sub}_FA.nii.gz
	done


cd $tbssdir
tbss_non_FA MD

fi





## Longitudinal run
if [[ $longitudinal -eq 1 ]]; then 

	mkdir $tbssdir/longitudinal_tbss/MD
	
	for origfile in $(ls $tbssdir/MD/*FA.nii.gz); do 
	
		mdfile=$(basename $origfile);

		subname=$(echo $mdfile | cut -d "_" -f 1);

		if [[ $(ls -d ${fadir}/*${subname}* | grep -v _1 | wc -l) -ge 1 ]]; then  ## If they have longitudinal data
			echo $subname; 
		
			for subfold in $(ls -d ${fadir}/*${subname}* | grep -v _1); do  ## copy data to longitudinal folder 
				nameTP=$(basename $subfold)	
				cp ${subfold}/dwi/DTIfit_MD.nii.gz $tbssdir/longitudinal_tbss/MD/${nameTP}_FA.nii.gz; 
			done
		fi

	done 

cd $tbssdir/longitudinal_tbss
tbss_non_FA MD
fi 


