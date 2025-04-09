module load fsl/6.0.7.6 GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels  #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/
QCdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/FixelAnalysis/QC
singularity=/opt/aumc-containers/singularity/qsiprep/qsiprep-0.19.1.sif

mkdir -p $QCdir/qc_fod_images/ses-01
mkdir -p $QCdir/qc_fod_images/ses-02
mkdir -p $QCdir/qc_fod_images/ses-03


for sub in `ls -d ${fixeldir}/subjects/sub* | grep -v html`; do 
subname=`basename $sub`; 
echo $subname; 

for ses in `ls -d ${fixeldir}/subjects/${subname}/ses*`; do   

sesname=`basename $ses`;  
echo $sesname; 

	
	###create qc image for subject level response wmfod
	if [[ -f ${fixeldir}/subjects/${subname}/${sesname}/dwi/${subname}_${sesname}_space-FODtemplate_brain_mask.mif ]] && [[ ! -f ${QCdir}/qc_fod_images/${sesname}/${subname}_${sesname}0000.png ]]; then

		mrview ${fixeldir}/subjects/${subname}/${sesname}/dwi/${subname}_${sesname}_space-FODtemplate_brain_mask.mif -mode 2 -capture.folder $QCdir/qc_fod_images/${sesname}/ -capture.prefix ${subname}_${sesname} -capture.grab -exit 

	else 
		echo "qc image already done for $subname"
	fi
	done
done
