qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis

# make directory to store data 
if [[ ! -d ${fixeldir}/subjects ]]; then 
	mkdir ${fixeldir}/subjects; 
fi

# make template directory 
if [[ ! -d ${fixeldir}/template ]]; then 
	mkdir ${fixeldir}/template; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/mask_images ]]; then 
	mkdir ${fixeldir}/mask_images; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/FOD_images ]]; then 
	mkdir ${fixeldir}/FOD_images; 
fi

for subject in $(cat $scriptsdir/subjects_to_be_processed.txt); do 
echo $subject;
sub=`basename $subject`
if [[ ! -f ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif ]]; then

	sbatch $scriptsdir/make_fod_old/make_fod_def.sh $subject
	mkdir -p $scriptsdir/subjects/$sub

	while [[ $(ls $scriptsdir/subjects/ | wc -l) = 19 ]]; do
		sleep 5;
	done
else
	echo "$sub has been already processed"
fi
done

