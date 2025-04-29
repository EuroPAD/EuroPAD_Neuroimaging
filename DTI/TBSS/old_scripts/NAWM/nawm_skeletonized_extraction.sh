## First subject
# 011EPAD00001

######### TRIALS #########
subjectname=011EPAD00001
fslroi /home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/stats/all_FA_skeletonised.nii.gz subj1 1 1 

wmhmask=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives//ExploreASL/analysis/011EPAD00001_1/WMH_SEGM.nii.gz

fsltemplate1mm=/opt/aumc-apps/fsl/fsl-6.0.5.1/data/standard/MNI152_T1_1mm.nii.gz

antsApplyTransforms  -d 3 -i /home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives//ExploreASL/analysis/011EPAD00001_1/WMH_SEGM.nii.gz  -r  /opt/aumc-apps/fsl/fsl-6.0.5.1/data/standard/MNI152_T1_1mm.nii.gz -o rSegmentation_WMH.nii.gz -n BSpline -t  /home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives//ExploreASL/analysis/011EPAD00001_1/y_T1.nii.gz

### THIS is to compute the registration 
antsRegistrationSyN.sh -d 3 -f /opt/aumc-apps/fsl/fsl-6.0.5.1/data/standard/MNI152_T1_1mm.nii.gz -m ../../derivatives/ExploreASL/analysis/011EPAD00001_1/FLAIR.nii.gz -o flair2mni

### important
fslorient -copysform2qform FLAIR.nii.gz




######### NAWM SCRIPT ###########

#1. for each subject, align (fslorient) FLAIR and WMH mask because of the error that we found 

#2. FLAIR (WMH) to dti (MNI 1 by 1 by 1) --> compute the registration : you can do it with ANTS or ELASTICS

#3 Apply the registration to the WMH mask, --> we should get the WMH mask in MNI space

#4. Mask the FA with the WMH mask (in MNI) 

#5. concatenate them in one file (e.g. all_FA_NAWM.nii.gz) --> fslmerge -t "list of files"

fslmerge -t 

#1, Aligning FLAIR and WMH mask
subj=011EPAD00010
subj_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/ExploreASL/analysis/011EPAD00010_1
output_dir=/home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/

fslorient -copysform2qform FLAIR.nii.gz
