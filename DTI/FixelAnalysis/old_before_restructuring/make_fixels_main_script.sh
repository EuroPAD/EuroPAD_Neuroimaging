qsirecdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsirecon-v0.19.0 #original qsirecon output
qsiprepdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/qsiprep-v0.19.0 #original qsiprep output
fixeldir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/derivatives/fixel_qsirecon-v0.19.0 #outpt fixel directory
scriptsdir=/home/radv/$(whoami)/my-rdisk/r-divi/RNG/Projects/ExploreASL/EuroPAD/code/multimodal_MRI_processing/DTI/FixelAnalysis

module load  GCC/9.3.0  OpenMPI/4.0.3 MRtrix/3.0.3-Python-3.8.2

# make directory to store data 
if [[ ! -d ${fixeldir}/subjects ]]; then 
	mkdir ${fixeldir}/subjects; 
fi

# make template directory 
if [[ ! -d ${fixeldir}/template ]]; then 
	mkdir ${fixeldir}/template; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/mask_images ]]; then 
	mkdir ${fixeldir}/mask_images; 
fi

# make mask directory 
if [[ ! -d ${fixeldir}/FOD_images ]]; then 
	mkdir ${fixeldir}/FOD_images; 
fi

###Check if upsampled DWI exists
for sub in `ls -d ${qsiprepdir}/sub* | grep -v html`; do 

subname=`basename $sub`; 
echo $subname;

for ses in `ls -d ${qsiprepdir}/${subname}/ses*`; do   

sesname=`basename $ses`;  
echo $ses;  

if [[ ! -f ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_mask_upsampled.mif ]]; then 

mrconvert ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.nii.gz ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif -fslgrad ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.bvec ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_space-T1w_desc-preproc_dwi.bval -force
 
#create upsampled DWI
mrgrid ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif regrid -vox 1.25 ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi_upsampled.mif -force

#create upsampled masks
dwi2mask ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi_upsampled.mif ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_mask_upsampled.mif -force

rm ${qsiprepdir}/${subname}/${sesname}/dwi/${subname}_${sesname}_dwi.mif

fi
done
done

#compute average fod
response_files_wm=()
response_files_gm=()
response_files_csf=()

for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 

subname=`basename $sub`; 
echo $subname;

if [[ -f ${qsirecdir}/${subname}/ses-01/dwi/${subname}_ses-01_space-T1w_desc-preproc_desc-wmFOD_ss3tcsd.txt ]]; then 

file_wm=${qsirecdir}/${subname}/ses-01/dwi/${subname}_ses-01_space-T1w_desc-preproc_desc-wmFOD_ss3tcsd.txt
file_gm=${qsirecdir}/${subname}/ses-01/dwi/${subname}_ses-01_space-T1w_desc-preproc_desc-gmFOD_ss3tcsd.txt
file_csf=${qsirecdir}/${subname}/ses-01/dwi/${subname}_ses-01_space-T1w_desc-preproc_desc-csfFOD_ss3tcsd.txt

response_files_wm+=($file_wm)
response_files_gm+=($file_gm)
response_files_csf+=($file_csf)
fi
done

#remove subjects from the arrays based on visual QC
for sub in $(cat $scriptsdir/subjects_to_exclude_from_fixel.txt); do 
response_files_wm=( $( printf '%s\n' ${response_files_wm[*]} | egrep -v $sub ) ); 
done

for sub in $(cat $scriptsdir/subjects_to_exclude_from_fixel.txt); do 
response_files_gm=( $( printf '%s\n' ${response_files_gm[*]} | egrep -v $sub ) ); 
done

for sub in $(cat $scriptsdir/subjects_to_exclude_from_fixel.txt); do 
response_files_csf=( $( printf '%s\n' ${response_files_csf[*]} | egrep -v $sub ) ); 
done

responsemean ${response_files_wm[*]} ${qsirecdir}/group_average_response_wm.txt -force
responsemean ${response_files_gm[*]} ${qsirecdir}/group_average_response_gm.txt -force
responsemean ${response_files_csf[*]} ${qsirecdir}/group_average_response_csf.txt -force

# Create a list of subjects that need the FOD image estimated from the average response
rm $scriptsdir/subjects_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
echo $subname; 
if [ ! -f ${qsirecdir}/${subname}/ses-01/dwi/group_average_response_wmfod.mif ]; then 
	echo $sub >> $scriptsdir/subjects_to_be_processed.txt;
fi; 
done

#compute FOD images using average response #MRtrix3Tissue is needed here https://3tissue.github.io/doc/
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : ss3t_csd_beta1 ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_dwi_upsampled.mif ${qsirecdir}/group_average_response_wm.txt IN/ses-01/dwi/NAME_ses-01_group_average_response_wmfod.mif ${qsirecdir}/group_average_response_gm.txt IN/ses-01/dwi/NAME_ses-01_group_average_response_gm.mif ${qsirecdir}/group_average_response_csf.txt IN/ses-01/dwi/NAME_ses-01_group_average_response_csf.mif -mask ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_mask_upsampled.mif -force

#joint bias field correction and intensity normalization
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mtnormalise IN/ses-01/dwi/NAME_ses-01_group_average_response_wmfod.mif IN/ses-01/dwi/NAME_ses-01_group_average_response_wmfod_norm.mif IN/ses-01/dwi/NAME_ses-01_group_average_response_gm.mif IN/ses-01/dwi/NAME_ses-01_group_average_response_gm_norm.mif IN/ses-01/dwi/NAME_ses-01_group_average_response_csf.mif IN/ses-01/dwi/NAME_ses-01_group_average_response_csf_norm.mif -mask ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_mask_upsampled.mif -force

### Template Creation from selected subjects
if [ ! -f $fixeldir/template/fod_template.mif ]; then 
	for_each `cat $scriptsdir/fixel_template_subjects.txt` : cp ${qsirecdir}/IN/ses-01/dwi/IN_ses-01_group_average_response_wmfod_norm.mif $fixeldir/FOD_images 
	for_each `cat $scriptsdir/fixel_template_subjects.txt` : cp ${qsiprepdir}/IN/ses-01/dwi/IN_ses-01_mask_upsampled.mif $fixeldir/mask_images  
	population_template $fixeldir/FOD_images -mask_dir $fixeldir/mask_images $fixeldir/template/fod_template.mif
	rm -r $fixeldir/FOD_images
else 
	echo "Template has already been done"
fi

###  Create folders structure  ###
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 

subname=`basename $sub`; 
echo $subname; 

if [[ ! -d $fixeldir/subjects/${subname} ]]; then 
	mkdir $fixeldir/subjects/${subname}; 
fi; 

for ses in `ls -d ${qsirecdir}/${subname}/ses*`; do   

echo $ses; sesname=`basename $ses`;  

if [[ ! -d $fixeldir/subjects/${subname}/${sesname} ]]; then 
	mkdir $fixeldir/subjects/${subname}/${sesname}; mkdir $fixeldir/subjects/${subname}/${sesname}/dwi ; 
fi; 

rm -r $fixeldir/subjects/${subname}/ses-02 # remove other sessions for the moment
rm -r $fixeldir/subjects/${subname}/ses-03
done; 
done

# Remove subjects from QC list
for_each $(cat $scriptsdir/subjects_to_exclude_from_fixel.txt) : rm -r $fixeldir/subjects/NAME 

# Create a list of subjects that have to be processed #if template needs to be re-done, go through all steps again
rm $scriptsdir/subjects_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do 
subname=`basename $sub`; 
echo $subname; 
if [ ! -f ${fixeldir}/subjects/$subname/ses-01/dwi/template_to_* ]  && [[ -d ${fixeldir}/subjects/$subname/ses-01 ]]; then 
	echo $sub >> $scriptsdir/subjects_to_be_processed.txt;
fi; 
done

# Compute the transformation (mrregister) of the WM FOD to the group template 
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrregister IN/ses-01/dwi/NAME_ses-01_group_average_response_wmfod_norm.mif -mask1 ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_mask_upsampled.mif $fixeldir/template/fod_template.mif -nl_warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif $fixeldir/subjects/NAME/ses-01/dwi/template_to_NAME.mif -force

# Apply the computed transformation to the masks
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrtransform ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_mask_upsampled.mif -warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif -interp nearest $fixeldir/subjects/NAME/ses-01/dwi/NAME_ses-01_space-FODtemplate_brain_mask.mif -force


### Include all subjects in the next two steps
# Take the intersection of the masks and create a group mask
mrmath $fixeldir/subjects/*/ses-01/dwi/sub*space-FODtemplate_brain_mask.mif min $fixeldir/template/group_mask_intersection.mif -datatype bit -force

# Compute fixels on group template within the group mask
rm -rf  $fixeldir/template/fixel_mask/
fod2fixel -mask $fixeldir/template/group_mask_intersection.mif -fmls_peak_value 0.06 $fixeldir/template/fod_template.mif $fixeldir/template/fixel_mask -force

### Peform only on subjects that are processed for the first time
# Create a list of subjects to process
rm $scriptsdir/subjects_to_be_processed.txt
for sub in `ls -d ${fixeldir}/subjects/sub*`; do
subname=`basename $sub`; 
echo $subname; 
if [ ! -f ${fixeldir}/subjects/$subname/ses-01/dwi/*ses-01_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif ] && [[ -d ${fixeldir}/subjects/$subname/ses-01 ]]; then 
	echo $sub >> $scriptsdir/subjects_to_be_processed.txt;
fi; 
done

# Warp subjects FOD images in to template space, without reorientation of FODs (performed later)
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrtransform ${qsirecdir}/NAME/ses-01/dwi/NAME_ses-01_group_average_response_wmfod_norm.mif -warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif -reorient_fod no $fixeldir/subjects/NAME/ses-01/dwi/NAME_ses-01_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif -force

### Include all subjects from now on
# Segment subjects' FOD images, to estimate fixels and apparent fibers density
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_wmFixels_not_reoriented
for_each $fixeldir/subjects/* : fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_group_average_response_wmfod_norm_not_reoriented.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels_not_reoriented -afd fd.mif -force

# Now reorient the fixels based on local transformation taken from previous warps
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_wmFixels
for_each $fixeldir/subjects/* : fixelreorient IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels_not_reoriented IN/ses-01/dwi/NAME_to_template.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels

# match fixels from each individual to te template ones
rm $fixeldir/template/fd/index.mif
rm $fixeldir/template/fd/directions.mif
for_each $fixeldir/subjects/* : fixelcorrespondence IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_wmFixels/fd.mif $fixeldir/template/fixel_mask $fixeldir/template/fd PRE.mif -force

# Compute Fibre crossection (FC) from the warps
rm $fixeldir/template/fc/index.mif
rm $fixeldir/template/fc/directions.mif
for_each $fixeldir/subjects/* : warp2metric IN/ses-01/dwi/NAME_to_template.mif -fc $fixeldir/template/fixel_mask $fixeldir/template/fc PRE.mif -force

# Log FC
if [[ ! -d $fixeldir/template/log_fc ]]; then 
mkdir $fixeldir/template/log_fc
fi
cp $fixeldir/template/fc/index.mif $fixeldir/template/log_fc
cp $fixeldir/template/fc/directions.mif $fixeldir/template/log_fc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fc/PRE.mif -log $fixeldir/template/log_fc/PRE.mif -force

# Compute FDC
if [[ ! -d $fixeldir/template/fdc ]]; then
mkdir $fixeldir/template/fdc
fi
cp $fixeldir/template/fc/index.mif $fixeldir/template/fdc
cp $fixeldir/template/fc/directions.mif $fixeldir/template/fdc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fd/PRE.mif $fixeldir/template/fc/PRE.mif -mult $fixeldir/template/fdc/PRE.mif -force

# run tractography on the template 
cd $fixeldir/template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 fod_template.mif -seed_image group_mask_intersection.mif -mask group_mask_intersection.mif -select 20000000 -cutoff 0.1 tracks_20_million.tck -force

tcksift tracks_20_million.tck fod_template.mif tracks_2_million_sift.tck -term_number 2000000 -force # filter

# Fixel Connectivity
fixelconnectivity fixel_mask/ tracks_2_million_sift.tck matrix/ -force

# Fixel filtering (smoothing)
rm $fixeldir/template/fd_smooth/index.mif
rm $fixeldir/template/fd_smooth/directions.mif
fixelfilter fd smooth fd_smooth -matrix matrix/ -force

rm $fixeldir/template/log_fc_smooth/index.mif
rm $fixeldir/template/log_fc_smooth/directions.mif
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/ -force

rm $fixeldir/template/fdc_smooth/index.mif
rm $fixeldir/template/fdc_smooth/directions.mif
fixelfilter fdc smooth fdc_smooth -matrix matrix/ -force

# Create files.txt for statistical analysis
rm ${fixeldir}/template/files.txt
for sub in `ls -d ${fixeldir}/template/fd_smooth/sub*`; do
subname=`basename $sub`; 
	echo $subname >> ${fixeldir}/template/files.txt;
done

