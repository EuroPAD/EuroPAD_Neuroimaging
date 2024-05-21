pet=/pet/*acstat_pet.nii.gz

#pet smoothing
fslmaths $pet -s 8 pet_smoothed.nii.gz
