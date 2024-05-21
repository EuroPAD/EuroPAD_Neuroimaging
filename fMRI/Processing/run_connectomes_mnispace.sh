fmriprepdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/fmriprep
atlas=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/atlases/Schaefer400_space-MNI152NLin6_res-2x2x2.nii.gz
scriptdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/fMRI/Processing

for sub in `ls -d $fmriprepdir/sub-* | grep -v html`; do
echo $sub; 
subjname=`basename $sub`
for ses in `ls -d $sub/ses*`; do 
echo $ses; 
sessioname=`basename $ses`
python $scriptdir/compute_mni_connectome.py $ses/func/${subjname}_${sessioname}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz -a $atlas
done 
 
done



