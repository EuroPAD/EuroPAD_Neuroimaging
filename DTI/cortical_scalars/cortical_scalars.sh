#!/bin/bash
# Bash Dependencies:
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load fsl

scriptsdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing
codedir=$(dirname $(realpath $BASH_SOURCE)) # location of script
studydir=$(realpath $(echo $codedir/../../..)) # location of BIDS directory

atlasname=schaefer100nosubcortical # name of the atlas in the qsirecfolder
LUT= # Add path to LUT
qsirecdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/llorenzini/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output



#which session?
ses=ses-01


for subname in $(ls -d $qsirecdir/sub* | grep -v html ); do 

sub=`basename $subname`; 
echo $sub 

# create folder for output
if [[ ! -d ${subname}/${ses}/dwi/cortical_scalars ]]; then 
	mkdir ${subname}/${ses}/dwi/cortical_scalars
fi



# Check if GM in T1 space already exists, otherwise run and skeletonized atlas
if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz ]]; then 

	# extract first volume of segmentation 
	fslroi ${subname}/${ses}/anat/${sub}_desc-preproc_desc-hsvs_5tt.nii.gz ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz 0 1 

	# from FS native to T1w space
	antsApplyTransforms -i ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz  -r $qsiprepdir/$sub/$ses/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz  -d 3 -o ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -n linear -t $qsiprepdir/$sub/$ses/anat/${sub}_${ses}_from-orig_to-T1w_mode-image_xfm.txt -v

	# Binarize GM mask 
	fslmaths ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -thr 0.2 -bin ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz

	#multiply atlas per gm bin 
fslmaths ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz -mas  ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz
fi





# IF IT HAS NOT BEEN DONE FOR THIS ATLAS, COMPUTE
if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt ]]; then

	touch ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt
	touch ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


	## IF LUT EXIST OTHERWISE USE FSLSTATS
	if [[ -f $LUT ]]; then 

		# iterate across column one
		for labelN in `sed 's/|/ /' $LUT | awk '{print $1}'`; do 

		#FA 
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	else ## otherwise we try with fslstats

	numboflab=`fslstats ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz -R | cut -d " " -f2`

		
		# iterate across column one
		for labelN in $(seq 1 $numboflab); do 
		#FA 
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	fi

fi

done



## Create group file
if [[ ! -d $qsirecdir/cortical_scalars ]] ; then 
mkdir $qsirecdir/cortical_scalars;
fi

touch $qsirecdir/cortical_scalars/${atlasname}_${ses}_cortical_FA.txt 
touch $qsirecdir/cortical_scalars/${atlasname}_${ses}_cortical_MD.txt 
for subname in $(ls -d $qsirecdir/sub* | grep -v html ); do 

sub=`basename $subname`; 
echo $sub 

####### FA #########
#Transpose and add sub name

rm tmp1.txt
rm tmp2.txt

echo $sub > tmp1.txt
input_file=${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt
n_cols=$(head -1 "$input_file" | wc -w)
for i in $(seq 1 "$n_cols"); do
    echo $(cut -d ' ' -f "$i" "$input_file")
done >> tmp2.txt 

paste -d ' ' tmp1.txt tmp2.txt >> $qsirecdir/cortical_scalars/${atlasname}_${ses}_cortical_FA.txt  


####### MD #########
#Transpose and add sub name

rm tmp1.txt
rm tmp2.txt

echo $sub > tmp1.txt
input_file=${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt
n_cols=$(head -1 "$input_file" | wc -w)
for i in $(seq 1 "$n_cols"); do
    echo $(cut -d ' ' -f "$i" "$input_file")
done >> tmp2.txt 

paste -d ' ' tmp1.txt tmp2.txt >> $qsirecdir/cortical_scalars/${atlasname}_${ses}_cortical_MD.txt  

done


