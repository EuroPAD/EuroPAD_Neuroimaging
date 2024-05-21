qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario

for sub in $(cat ${scriptsdir}/subjects_to_be_processed.txt); do 
subname=`basename $sub`;
for session in $(ls -d $sub/ses-01); do 
sesname=`basename $session`;

if [ -f ${fixeldir}/subjects/${subname}/${sesname}/dwi/*space-FODtemplate_brain_mask.mif ]; then 
echo "$subname has been processed" >> ${scriptsdir}/fod_registration_check.txt
fi
done
done
