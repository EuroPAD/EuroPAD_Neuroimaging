## Use a new parcelltion to compute the connectome on the qsiprep output
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load FreeSurfer
scriptsdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing

qsirecdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
FSdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/Freesurfer_crossectional


for subname in $(ls -d $qsirecdir/sub* | grep -v html); do 


if [[ ! -f ${subname}/ses-01/dwi/extra_connectomes/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas_sift_invnodevol_radius2_count_connectome.csv ]]; then 


echo $subname; 
sub=`basename $subname`; 
echo $sub 


#### Take FS parcellation and do the label convert

fsparc=$FSdir/$sub/mri/aparc+aseg.mgz

if [[ ! -f $fsparc ]]; then
echo "FS parcellation not found for $sub, skipping ..."; 
continue
fi


labelconvert $fsparc $FREESURFER_HOME/FreeSurferColorLUT.txt ~/fs_default_DKcortical68.txt ${subname}/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas.mif

if [[ ! -d $qsirecdir/$sub/ses-01/dwi/extra_connectomes ]]; then 
mkdir $qsirecdir/$sub/ses-01/dwi/extra_connectomes; 
fi 

cp ~/fs_default_DKcortical68.txt $qsirecdir/$sub/ses-01/dwi/extra_connectomes/DK68cortical_LUT.txt # copy the schaeffer lut 

# just count
tck2connectome $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas.mif $qsirecdir/$sub/ses-01/dwi/extra_connectomes/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas_radius2_count_connectome.csv -symmetric

# sift2 count
tck2connectome $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas.mif $qsirecdir/$sub/ses-01/dwi/extra_connectomes/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas_sift_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -out_assignments $qsirecdir/$sub/ses-01/dwi/extra_connectomes/DK68cortical_atlas_assignments.txt -symmetric

# mean length
tck2connectome $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas.mif $qsirecdir/$sub/ses-01/dwi/extra_connectomes/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas_radius2_meanlength_connectome.csv -scale_length -stat_edge mean -symmetric

# sift2 count scaled inv node vol
tck2connectome $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-tracks_ifod2.tck ${subname}/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas.mif $qsirecdir/$sub/ses-01/dwi/extra_connectomes/${sub}_ses-01_space-T1w_desc-preproc_desc-DK68cortical_atlas_sift_invnodevol_radius2_count_connectome.csv -tck_weights_in $qsirecdir/$sub/ses-01/dwi/${sub}_ses-01_space-T1w_desc-preproc_desc-siftweights_ifod2.csv -scale_invnodevol -symmetric


fi

done
