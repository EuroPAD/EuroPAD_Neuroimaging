echo "Generating lists list_NAWM_050_FA.txt and list_NAWM_050_MD.txt..."
ls /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/*_nawm_050_FA.nii.gz > list_nawm_050_FA.txt 
#sort list_nawm_050_FA.txt >> list_nawm_050_FA.txt
ls /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/TBSS/NAWM_FA/*_nawm_050_MD.nii.gz > list_nawm_050_MD.txt
#sort list_nawm_050_MD.txt >> list_nawm_050_MD.txt
echo "Lists generated!"

function confirm() {
    while true; do
        read -p "Do you want to concatenate all FA & MD files into one 4D FA and one 4D MD file? (y/n/c)" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            [Cc]* ) exit;;
            * ) echo "Please answer (y)es, (n)o, or (c)ancel.";;
        esac
    done
}

if confirm; then
    echo "YES: Concatenating... this will take some time (10+ minutes per scalar)!"
	fslmerge -t all_nawm_050_FA.nii.gz $(cat /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/list_NAWM_050_FA.txt)
	echo "(1/2) Done! Concatenated file saved as all_nawm_050_FA.nii.gz"
	fslmerge -t all_nawm_050_MD.nii.gz $(cat /home/radv/lpieperhoff/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/DTI/TBSS/NAWM/list_NAWM_050_MD.txt)
	echo "(2/2) Done! Concatenated file saved as all_nawm_050_MD.nii.gz"
else
    echo "User chose NO. Aborting the operation..."
fi



echo "Script finished."
