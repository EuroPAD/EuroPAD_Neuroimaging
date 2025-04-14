These are ANTS affine/warp parameter files for transforming between MNI152 and MCALT space.

They was created by:
ANTS 3 -m  CC[ MCALT_T1_05mm.nii , MNI152_T1_1mm.nii.gz , 1, 5 ] -o MNI152_to_MCALT_ -i 30x90x20 -r Gauss[3,0] -t SyN[0.25]

Example usage MNI to MCALT:
antsApplyTransforms -i MNI152_T1_1mm.nii.gz -o MNI_in_MCALT.nii -r MCALT_T1.nii -t MNI152_to_MCALT_Warp.nii.gz -t MNI152_to_MCALT_Affine.txt

For label images (e.g. atlas regions), use -n GenericLabel

For transforming MCALT to MNI, replace -r and -t flags with -r MNI152_T1_1mm.nii.gz  and -t [MNI152_to_MCALT_Affine.txt,1] -t MNI152_to_MCALT_InverseWarp.nii.gz
