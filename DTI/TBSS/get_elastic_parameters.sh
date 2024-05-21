
CD=${PWD}

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
