#!/bin/bash
#SBATCH --job-name=denoisefmri    # a convenient name for your job
#SBATCH --mem=10G               # max memory per node
#SBATCH --partition=luna-short # using luna short queue
#SBATCH --cpus-per-task=1      # max CPU cores per process
#SBATCH --time=00:30:00         # time limit (DD-HH:MM)
#SBATCH --nice=1000            # allow other priority jobs to go first
#SBATCH --array=1-6%2

echo "REMINDER THAT THIS IS A JOB ARRAY AND YOU SHOULD ADJUST THE --ARRAY OPTION BASED ON THE NUMBER OF FILES TO BE PROCESSED"



module load fsl
module load R
module load rstudio


bidsoutput=/scratch/radv/llorenzini/Projects/alpha-synu/derivatives/fmriprep-v23.2.3



# get participant name
participantdir=`ls -d $bidsoutput/sub* | grep -v html | head "-$SLURM_ARRAY_TASK_ID" | tail -1` 
participant=`basename $participantdir`

echo "denoising subject $participant"
 
## iterate across sections
for sesdir in `ls -d $participantdir/ses* `; do 


ses=`basename $sesdir`; 

echo "..session $ses"

confoundfile=$sesdir/func/${participant}_${ses}_task-rest_desc-confounds_timeseries.tsv;
selectedconfoundfile=${confoundfile//_timeseries.tsv/Selected_timeseries.txt}



Rscript auxilliary_functions/select_fmri_confounds.R $confoundfile $selectedconfoundfile

# run denoising for each preprocessed file (in different spaces if there are
for preprocbold in `ls $sesdir/func/*preproc_bold.nii.gz`; do 

denoisebold=${preprocbold//desc-preproc_bold/desc-preprocDenoised_bold};
smoothbold=${denoisebold//desc-preprocDenoised_bold/desc-preprocDenoisedSmooth_bold};

echo "removing noise with fsl_regfilt"
# regress out noise
echo "running command : fsl_regfilt -i  $preprocbold -d  $selectedconfoundfile -o  $denoisebold -f "1,2,3,4,5,6,7,8,9,10,11,12,13,14" -v"

fsl_regfilt -i  $preprocbold \
            -d  $selectedconfoundfile \
            -o  $denoisebold \
            -f "1,2,3,4,5,6,7,8,9,10,11,12,13,14" \
            -v ;

echo "smoothing"

## smooth 
fslmaths $denoisebold -s 4 $smoothbold;

done

done
