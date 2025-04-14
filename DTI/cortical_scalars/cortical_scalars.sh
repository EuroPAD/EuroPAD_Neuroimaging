#!/bin/bash
## this script computes DTI scalars (FA and MD) within gray matter regions. 
# Settings for this script, including directories and atlas definition, is done in a separate script called "set_paths.sh", which is run at the beginnign of this one. 
# to change options, you need to change the set_paths.sh script. 
# the atlas is multiplied with the GM segmentation from freesurfer, and FA and MD are then averaged within each region.  


# Bash Dependencies:
module load ANTs/2.4.1
module load GCC/9.3.0 OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2
module load fsl

. set_paths.sh


for subname in $(ls -d $qsirecdir/sub* | grep -v html ); do 

sub=`basename $subname`; 
echo $sub 

## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 


ses=`basename $sesfold`;
echo $ses;



# create folder for output
if [[ ! -d ${subname}/${ses}/dwi/cortical_scalars ]]; then 
	mkdir ${subname}/${ses}/dwi/cortical_scalars
fi



	
# check if the FS has already been put in native space (for another atlas?)

if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz ]]; then
		
	# extract first volume of segmentation 
	fslroi ${subname}/${ses}/anat/${sub}_desc-preproc_desc-hsvs_5tt.nii.gz ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz 0 1; 

	# from FS native to T1w space
	antsApplyTransforms -i ${subname}/${ses}/dwi/cortical_scalars/FSnative_GM.nii.gz -r $qsiprepdir/$sub/$ses/dwi/${sub}_${ses}_space-T1w_desc-preproc_dwi.nii.gz -d 3 -o ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -n linear -t $qsiprepdir/$sub/$ses/anat/${sub}_${ses}_from-orig_to-T1w_mode-image_xfm.txt -v;

	# Binarize GM mask 
	fslmaths ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM.nii.gz -thr 0.2 -bin ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz;


fi

# Check if GM in T1 space already exists, otherwise run and skeletonized atlas
if [[ ! -f ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii ]]; then 
	
	if [[ $atlasname ==  DK84cortical ]]; then ## If is DK we dont multiply cause it is already from FS and has also the "subcortical regions"

		cp ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii

	else 
	#multiply atlas per gm bin 
		fslmaths ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas.nii.gz -mas  ${subname}/${ses}/dwi/cortical_scalars/FS_space-T1w_GM_bin.nii.gz ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz;

	fi
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
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	else ## otherwise we try with fslstats

	numboflab=`fslstats ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii.gz -R | cut -d " " -f2`

		
		# iterate across column one
		for labelN in $(seq 1 $numboflab); do 
		#FA 
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-dti_fa_gqiscalar.nii.gz -ignorezero --mask  - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt

		#MD
		mrcalc ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_space-T1w_desc-preproc_desc-${atlasname}_atlas_GM.nii  $labelN -eq - | mrstats ${subname}/${ses}/dwi/${sub}_${ses}_space-T1w_desc-preproc_desc-md_gqiscalar.nii.gz -ignorezero --mask - -output median >> ${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt


		done

	fi

fi

done

done





## Create group file
if [[ ! -d $qsirecdir/cortical_scalars ]] ; then 
mkdir $qsirecdir/cortical_scalars;
fi

if [[ -f $qsirecdir/cortical_scalars/${atlasname}_cortical_FA.txt ]]; then 

rm $qsirecdir/cortical_scalars/${atlasname}_cortical_FA.txt ;
rm $qsirecdir/cortical_scalars/${atlasname}_cortical_MD.txt ;

fi


touch $qsirecdir/cortical_scalars/${atlasname}_cortical_FA.txt 
touch $qsirecdir/cortical_scalars/${atlasname}_cortical_MD.txt 


for subname in $(ls -d $qsirecdir/sub* | grep -v html ); do 

sub=`basename $subname`; 
echo $sub 

## iterate sessions
for sesfold in $(ls -d $subname/ses*); do 


ses=`basename $sesfold`;
echo $ses;



####### FA #########
#Transpose and add sub name

rm tmp1.txt
rm tmp2.txt

echo $sub $ses > tmp1.txt
input_file=${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_FA_cortical_scalars_${atlasname}_atlas.txt
n_cols=$(head -1 "$input_file" | wc -w)
for i in $(seq 1 "$n_cols"); do
    echo $(cut -d ' ' -f "$i" "$input_file")
done >> tmp2.txt 

paste -d ' ' tmp1.txt tmp2.txt >> $qsirecdir/cortical_scalars/${atlasname}_cortical_FA.txt  


####### MD #########
#Transpose and add sub name

rm tmp1.txt
rm tmp2.txt

echo $sub $ses > tmp1.txt
input_file=${subname}/${ses}/dwi/cortical_scalars/${sub}_${ses}_MD_cortical_scalars_${atlasname}_atlas.txt
n_cols=$(head -1 "$input_file" | wc -w)
for i in $(seq 1 "$n_cols"); do
    echo $(cut -d ' ' -f "$i" "$input_file")
done >> tmp2.txt 

paste -d ' ' tmp1.txt tmp2.txt >> $qsirecdir/cortical_scalars/${atlasname}_cortical_MD.txt  

done
done


