module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load fsl
module load FreeSurfer

scriptsdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing
codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=$(realpath $(echo $codedir/../../..)) # location of BIDS directory

atlasname=DK84cortical # name of the atlas in the qsirecfolder
LUT=$scriptsdir/atlases/fs_default_clean.txt # Add path to LUT# Add path to LUT
qsirecdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output
