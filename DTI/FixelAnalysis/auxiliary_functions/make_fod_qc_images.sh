module load fsl/6.0.7.6 GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/DTI/FixelAnalysis 
scratch=/home/radv/$(whoami)/my-scratch

mkdir -p $scratch/qc_fod_images/ses-000
mkdir -p $scratch/qc_fod_images/ses-001
mkdir -p $scratch/qc_fod_images/ses-002
mkdir -p $scratch/qc_fod_images/ses-005
mkdir -p $scratch/qc_fod_images/ses-006
mkdir -p $scratch/qc_fod_images/ses-007
mkdir -p $scratch/qc_fod_images/ses-03
mkdir -p $scratch/qc_fod_images/ses-04

for subject in `ls -d ${qsirecdir}/sub* | grep -v html | grep 030EPAD`; do 
	#for subject in $(cat $scriptsdir/subjects_to_be_processed.txt); do 
	sub=`basename $subject`
	echo $sub;
	for session in `ls -d ${qsirecdir}/${sub}/ses*`; do   
	ses=`basename $session`
	echo $ses
	
	###create qc image for group average response wmfod
	#if [[ -f ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif ]] && [[ ! -f $scratch/qc_fod_images/${sub}_ses-010000.png ]]; then

		#mrview ${qsirecdir}/${sub}/ses-01/dwi/${sub}_ses-01_group_average_response_wmfod_norm.mif -mode 2 -capture.folder $scratch/qc_fod_images/ -capture.prefix ${sub}_ses-01 -capture.grab -exit 

	#else 
#		echo "qc image already done for $sub"
	#fi
	#done

	###create qc image for subject level response wmfod
	if [[ -f ${qsirecdir}/${sub}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz ]] && [[ ! -f $scratch/qc_fod_images/${ses}/${sub}_${ses}0000.png ]]; then

		mrview ${qsirecdir}/${sub}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz -mode 2 -capture.folder $scratch/qc_fod_images/${ses}/ -capture.prefix ${sub}_${ses} -capture.grab -exit 

	else 
		echo "qc image already done for $sub"
	fi
	done
done
