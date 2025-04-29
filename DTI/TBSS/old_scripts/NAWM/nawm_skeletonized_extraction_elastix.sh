## First subject
# 011EPAD00001

CD=${PWD}

flair=FLAIR.nii.gz
wmhsegm=WMH_segm_bin.nii.gz
fsltemplate1mm=/opt/aumc-apps/fsl/fsl-6.0.5.1/data/standard/MNI152_T1_1mm.nii.gz

module load elastix;

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

CM="elastix -f $fsltemplate1mm -m $flair -out $CD -p Parameters_Rigid.txt -p Parameters_Affine.txt -p Parameters_BSpline.txt"
echo $CM
$CM

CM="transformix -in ${flair} -out ${CD} -tp TransformParameters.2.txt"
echo $CM
$CM
mv result.nii.gz ${flair//.nii/_mni.nii} 
CM="transformix -in ${wmhsegm} -out ${CD} -tp TransformParameters.2.txt"
echo $CM
$CM
mv result.nii.gz ${wmhsegm//.nii/_mni.nii}

