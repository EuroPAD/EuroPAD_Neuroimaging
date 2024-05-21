#!/bin/bash

CD=${PWD}
DD=${PWD%/*}/raw/Release/rawdata

# sand in the hourglass
sand="-\|/"

## all about the hourglass
##
#cntr=0;c2=0;
#cstr=$(printf "%04d" $cntr); let c2=$((${cntr}%4)); 
#printf "%s ...${cntr}...\r" ${sand:${c2}:1}; 
#let cntr=${cntr}+1;


PETSCANS=$CD/stat_pet.txt
MRSCANS=$CD/anat_mr.txt

printf "finding PET files ... "
if [[ ! -f $PETSCANS ]]; then 
	find $DD -name \*stat_pet\*nii\* > $PETSCANS; 
	rm -f $MRSCANS
fi
echo "done"

printf "finding corresponding MRI files ... "
if [[ ! -f $MRSCANS ]]; then 
	while read pet; do pdir=${pet%/*};mr=${pdir%/*}/anat;ls ${mr}/*T1w.nii.gz; done < $PETSCANS > $MRSCANS;
fi
echo "done"

# read both as arrays
ALLPET=( $(cat $PETSCANS) )
ALLMRI=( $(cat $MRSCANS)  )

# num. elements
nP=${#ALLPET[@]}
nM=${#ALLMRI[@]}

##############
## for elastix

baseURL="https://raw.githubusercontent.com/SuperElastix/ElastixModelZoo/master/models/default"
wget -nc ${baseURL}/Parameters_Rigid.txt   ## default / generally good params for rigid transforms
wget -nc ${baseURL}/Parameters_Affine.txt  ## default / generally good params for affine transforms
wget -nc ${baseURL}/Parameters_BSpline.txt ## default / generally good params for spline deformations

# only do this once! otherwise no niftis will be written (there are more WriteResult... lines)
if [[ ! -f ${CD}/Parameters_Rigid_P2M.txt ]]; then
	sed ${CD}/Parameters_Rigid.txt      -e 's|"mhd"|"nii.gz"|' > ${CD}/Parameters_Rigid_P2M.txt 
	sed ${CD}/Parameters_BSpline.txt    -e 's|"mhd"|"nii.gz"|' -e 's|"short"|"float"|' > ${CD}/Parameters_BSpline_MNI.txt
fi
sed -i ${CD}/Parameters_Rigid.txt   -e 's|(WriteResultImage "true")|(WriteResultImage "false")|'
sed -i ${CD}/Parameters_Affine.txt  -e 's|(WriteResultImage "true")|(WriteResultImage "false")|'
sed -i ${CD}/Parameters_BSpline.txt -e 's|(WriteResultImage "true")|(WriteResultImage "false")|'

###########
## for ANTs

module load ANTs/2.4.1

################
## start mapping

if [[ $nP == $nM ]]; then

	for (( i=0; i<nP; i++ )); do

		P=${ALLPET[$i]};
		M=${ALLMRI[$i]};
		printf "$i:\n\t$P\n\t$M\n"

	done

else

	echo "Please make sure that the numbers of PET and MR images are the same"

fi
