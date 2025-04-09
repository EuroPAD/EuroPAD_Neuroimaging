# maybe do 
# module load elastix itk/5.3.0 pycharm/22.3 GCCcore/11.2.0 fsl/6.0.5.1 Eigen/3.3.9 M4/1.4.19 pkg-config/0.29.2 Python/3.9.6 Autoconf/2.71 Automake/1.16.4 libtool/2.4.6 binutils/2.37 flex/2.6.4 gettext/0.21 pkg-config/0.29.2 CMake/3.21.1

#!/bin/bash


CD=${PWD};
PARENT_DIR=${CD%/*};
DD=${PARENT_DIR%/*}/derivatives/$(basename $CD)

################################################################################
## first find the input PET images
## these are smoothed averages in T1 space

PETFILES=${CD}/smooth_avg_pet.txt;
if [[ ! -f $PETFILES ]]; then

	printf "finding all the pet averages ... ";
	rm -f allpet.txt nopet.txt # recompute if no file $PETFILES found
	cm() { find ${PARENT_DIR%/*}/derivatives/ixico -type d -name ses-00\* -exec /bin/bash -c "ls {}/pet/*avg_pet*.nii*" \; >> allpet.txt 2>> nopet.txt; }
	time { cm; TIMEFORMAT="%2U"; }; 

	printf "finding the smoothed (harmonised) versions ... "
	rm -f nosmoothpet.txt;
	cm() { while read t1pet; do ls ${t1pet//_pet.nii/_desc-smooth_pet.nii}; done < allpet.txt >> $PETFILES 2>> nosmoothpet.txt; }
	time { cm; TIMEFORMAT="%2U"; }; 

fi ## [[ ! -f $PETFILES ]]

# read as array
AVGPET=( $(cat $PETFILES) );
nP=${#AVGPET[@]};

##############
## for elastix

baseURL="https://raw.githubusercontent.com/SuperElastix/ElastixModelZoo/master/models/default";
wget -nc ${baseURL}/Parameters_Rigid.txt   ## default / generally good params for rigid transforms
wget -nc ${baseURL}/Parameters_Affine.txt  ## default / generally good params for affine transforms
wget -nc ${baseURL}/Parameters_BSpline.txt ## default / generally good params for spline deformations

# only do this once! otherwise no niftis will be written (there are more WriteResult... lines)
if [[ ! -f ${CD}/Parameters_Rigid_P2M.txt ]]; then
	sed ${CD}/Parameters_Rigid.txt      -e 's|"mhd"|"nii.gz"|' > ${CD}/Parameters_Rigid_P2M.txt;
	sed ${CD}/Parameters_Affine.txt     -e 's|"mhd"|"nii.gz"|' > ${CD}/Parameters_Affine_coreg.txt;
	sed ${CD}/Parameters_BSpline.txt    -e 's|"mhd"|"nii.gz"|' -e 's|"short"|"float"|' > ${CD}/Parameters_BSpline_MNI.txt;
fi ## [[ ! -f ${CD}/Parameters_Rigid_P2M.txt ]]

cp ${CD}/Parameters_Affine_coreg.txt ${CD}/Parameters_Affine.txt;
cp ${CD}/Parameters_Rigid_P2M.txt    ${CD}/Parameters_Rigid.txt;
cp ${CD}/Parameters_BSpline_MNI.txt  ${CD}/Parameters_BSpline.txt;

sed -i ${CD}/Parameters_Rigid.txt   -e 's|(WriteResultImage "true")|(WriteResultImage "false")|';
sed -i ${CD}/Parameters_Affine.txt  -e 's|(WriteResultImage "true")|(WriteResultImage "false")|';
sed -i ${CD}/Parameters_BSpline.txt -e 's|(WriteResultImage "true")|(WriteResultImage "false")|';

regPET2MR=no ; # set to no if the PET are already in register with the MRI
regMR2MNI=yes; # set to yes for putting the T1 (and PET) in MNI space

######################################
# if anyone wants to reverse the array
# to run two scripts in opposite ways)
for (( i=${#AVGPET[@]}-1; i>=0; i-- )) do 
	AVGPETr[${#AVGPETr[@]}]=${AVGPET[i]};
done
AVGPET=("${AVGPETr[@]}");

RED='\033[0;31m';
NC='\033[0m'; # no colour

#####################
# loop over $PETFILES

for PETFILE in ${AVGPET[@]}; do

	PET_INPUT_DIR=${PETFILE%/*};             # PET directory, would end in /pet
	MRI_INPUT_DIR=${PET_INPUT_DIR%/*}/anat;  # MRI directory, would end in /anat
    
	PET_OUTPUT_DIR=${PET_INPUT_DIR//"/ixico/"/"/ixico-elastix-cb-suvr-mario/"};               # same as PET directory but different release root name
	MRI_OUTPUT_DIR=${PET_OUTPUT_DIR%/*}/anat;                                               # same as above but now /anat not /pet

	mkdir -p $PET_OUTPUT_DIR;
	mkdir -p $MRI_OUTPUT_DIR;

	MRIFILE=$(ls $MRI_INPUT_DIR/*T1w.nii.gz) # support a couple of different name styles

	PET_OUTPUTFILE=${PETFILE//$PET_INPUT_DIR/$PET_OUTPUT_DIR};                              # output files: same name as input but then in output directory
	MRI_OUTPUTFILE=${MRIFILE//$MRI_INPUT_DIR/$MRI_OUTPUT_DIR};

	if [[ $(find $PET_OUTPUT_DIR -name \*mni\*nii.gz) == "" ]] && [[ -f ${MRIFILE} ]]; then	

		echo "no mni space files in ${RED}$PET_OUTPUT_DIR${NC}.";

		# PET to MR with rigid parameters, then affine
		if [[ $regPET2MR == yes ]] && [[ ! -f $PET_OUTPUT_DIR/TransformParameters.1.txt ]]; then		

			rm -f ${PET_OUTPUT_DIR}/[ITer]*;
			CM="elastix -f $MRIFILE -m $PETFILE -out $PET_OUTPUT_DIR -p Parameters_Rigid.txt -p Parameters_Affine.txt";
			echo $CM;
			$CM 1> ${PET_OUTPUT_DIR}/elastix.log 2> ${PET_OUTPUT_DIR}/elastix.err;

		else

			ln -sf $PETFILE ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii};

		fi ## [[ ! -f $PET_OUTPUT_DIR/TransformParameters.1.txt ]]

		if [[ $regMR2MNI == yes ]] && [[ ! -f ${MRI_OUTPUT_DIR}/TransformParameters.2.txt ]]; then	

			TEMPLATE=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz;

			# MR to MNI-T1 with rigid parameters, then affine, then spline warp
			rm -f ${MRI_OUTPUT_DIR}/[ITer]*;
			CM="elastix -f $TEMPLATE -m $MRIFILE -out $MRI_OUTPUT_DIR -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt";
			echo $CM;
			$CM 1> ${MRI_OUTPUT_DIR}/elastix.log 2> ${MRI_OUTPUT_DIR}/elastix.err;

		fi ## [[ $regMR2MNI == yes ]] && [[ ! -f ${MRI_OUTPUT_DIR}/TransformParameters.2.txt ]]

		if [[ ! -f ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii} ]] || 
		   [[ ! -f ${MRI_OUTPUTFILE//_T1w.nii/_space-mni_T1w.nii} ]] || 
		   [[ ! -f ${PET_OUTPUTFILE//_pet.nii/_desc-resampled2x_space-mni_pet.nii} ]]; then

			echo -e "${RED}no resampling found${NC} in ${PET_OUTPUT_DIR}.";

			# apply the PET-to-T1w registration
			if [[ $regPET2MR == yes ]]; then 
				CM="transformix -in $PETFILE -out $PET_OUTPUT_DIR -tp ${PET_OUTPUT_DIR}/TransformParameters.1.txt";
				echo $CM;
				$CM 1> ${PET_OUTPUT_DIR}/transformixPET_T1w.log 2> ${PET_OUTPUT_DIR}/transformixPET_T1w.err;
				mv $PET_OUTPUT_DIR/result.nii.gz ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii}; 				fi;	

			# apply the warp of the T1w into MNI space
			CM="transformix -in $MRIFILE -out $MRI_OUTPUT_DIR -tp ${MRI_OUTPUT_DIR}/TransformParameters.2.txt";
			echo $CM;
			$CM 1> ${MRI_OUTPUT_DIR}/transformixMRstd.log 2> ${MRI_OUTPUT_DIR}/transformixMRstd.err;

			mv $MRI_OUTPUT_DIR/result.nii.gz ${MRI_OUTPUTFILE//_T1w.nii/_space-mni_T1w.nii};  

			# apply the T1w warp to the PET in T1w-space as well 
			CM="transformix -in ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii} -out $PET_OUTPUT_DIR -tp ${MRI_OUTPUT_DIR}/TransformParameters.2.txt";
			echo $CM;
			$CM 1> ${PET_OUTPUT_DIR}/transformixPETstd.log 2> ${PET_OUTPUT_DIR}/transformixPETstd.err;
			mv $PET_OUTPUT_DIR/result.nii.gz ${PET_OUTPUTFILE//_pet.nii/_space-mni_pet.nii};

		else

			echo -e "${RED}resampling found${NC} in ${PET_OUTPUT_DIR}.";

		fi ## [[ nifti files present? ]]

	else

		echo "skipping $PETFILE, mni file already exists.";

	fi ## [[ $(find $PET_OUTPUT_DIR -name \*mni\*nii.gz) == "" ]]

	SUVR_OUTPUTFILE=${PET_OUTPUTFILE//_pet.nii/_space-T1w_desc-suvrcereb_pet.nii}       # suvr: eaither PET (T1w or MNI space) divided by mean cerebellar grey

	if [[ ! -f ${SUVR_OUTPUTFILE} ]]; then 

		# make a mask of cerebellar grey from the atlas
		cmask=$(ls --ignore="*cereb*" ${MRI_INPUT_DIR} | grep dseg | grep nii);
		echo -e "${RED}$cmask${NC}";
		cgmask=${cmask//_dseg/_desc-cereb_dseg};
		CM="fslmaths ${MRI_INPUT_DIR}/${cmask} -thr 10 -uthr 13 ${MRI_INPUT_DIR//"/ixico/"/"/ixico-elastix-cb-suvr-mario/"}/$cgmask -odt char";
		echo $CM;
		$CM;

		# compute the mean PET in cerebellar grey
		MEANCGREY=${SUVR_OUTPUTFILE//.nii.gz/.txt}
		echo $MEANCGREY
		CM="fslstats ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii} -k ${MRI_INPUT_DIR//"/ixico/"/"/ixico-elastix-cb-suvr-mario/"}/${cgmask} -M";
		echo $CM;
		$CM > $MEANCGREY;

		# make T1w-space and MNI-space SUVR by dividing the two PET by mean cerebellar grey
		MEANCGREY=$(cat $MEANCGREY);
		CM="fslmaths ${PET_OUTPUTFILE//_pet.nii/_space-T1w_pet.nii}                  -div $MEANCGREY ${SUVR_OUTPUTFILE}";
		echo $CM;
		$CM;
		CM="fslmaths ${PET_OUTPUTFILE//_pet.nii/_space-mni_pet.nii} -div $MEANCGREY ${SUVR_OUTPUTFILE//_space-T1w_/_space-mni_}";
		echo $CM;
		$CM;

	fi ## [[ ! -f ${PET_OUTPUTFILE//_pet.nii/_space-T1w_desc-suvr_pet.nii} ]]

	echo -e "${RED}next${NC}"; # sleep 10000;

done ## for PETFILE in ${AVGPET[@]}


