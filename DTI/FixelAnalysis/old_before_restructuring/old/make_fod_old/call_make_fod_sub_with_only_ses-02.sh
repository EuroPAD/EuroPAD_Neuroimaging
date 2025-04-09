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

for sub in $(cat $scriptsdir/subjects_with_only_ses-02.txt); do 

if [[ ! -f ${qsirecdir}/${sub}/ses-02/dwi/${sub}_ses-02_group_average_response_wmfod_norm.mif ]]; then

	sbatch $scriptsdir/make_fod_old/make_fod_def_ses-02.sh $sub
	mkdir -p $scriptsdir/subjects/$sub

	while [[ $(ls $scriptsdir/subjects/ | wc -l) = 4 ]]; do
		sleep 5;
	done
else
	echo "$sub has been already processed"
fi
done

