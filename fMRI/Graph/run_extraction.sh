## modules 
module load Anaconda3/2022.05
conda activate luigi

disthis=$PWD
datadir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/fmriprep
ls -d $datadir/sub* | grep -v html > fulllist.txt
split -l 200 fulllist.txt smallerlist

for filelist  in `ls smallerlist*`; do 

sbatch sbatch_extract_graph_container.sh  $disthis/$filelist;

sleep 1

done
 




