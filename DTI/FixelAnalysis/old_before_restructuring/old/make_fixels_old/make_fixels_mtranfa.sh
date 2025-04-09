qsirecdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory
scriptsdir=/home/radv/mtranfa/my-rdisk/r-divi/RNG/Projects/ExploreASL/EPAD/scripts/mario

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

### Template Creation from selected subjects
if [ ! -f $fixeldir/template/fod_template.mif ]; then 
for_each `cat $scriptsdir/fixel_template_subjects.txt` : cp ${qsirecdir}/IN/ses-01/dwi/IN_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz $fixeldir/FOD_images 
 
for_each `cat $scriptsdir/fixel_template_subjects.txt` : cp ${qsiprepdir}/IN/ses-01/dwi/IN_ses-01_space-T1w_desc-brain_mask.nii.gz $fixeldir/mask_images  

population_template $fixeldir/FOD_images -mask_dir $fixeldir/mask_images $fixeldir/template/fod_template.mif

else 

echo "Template has already been done"
rm -r $fixeldir/FOD_images

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
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do #we need to reprocess them all (new template)
subname=`basename $sub`; 
echo $subname; 
if [ ! -f ${fixeldir}/subjects/$subname/ses-01/dwi/template_to_* ]  && [[ -d ${fixeldir}/subjects/$subname/ses-01 ]]; then 
	echo $sub >> $scriptsdir/subjects_to_be_processed.txt;
fi; 
done

# Compute the transformation (mrregister) of the WM FOD to the group template 
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrregister IN/ses-01/dwi/NAME_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz -mask1 ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-brain_mask.nii.gz $fixeldir/template/fod_template.mif -nl_warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif $fixeldir/subjects/NAME/ses-01/dwi/template_to_NAME.mif -force

# Apply the computed transformation to the masks
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrtransform ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-brain_mask.nii.gz -warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif -interp nearest $fixeldir/subjects/NAME/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-brain_mask.mif -force


### Include all subjects in the next two steps
# Take the intersection of the masks and create a group mask
mrmath $fixeldir/subjects/*/ses-01/dwi/sub*space-FODtemplate_desc-brain_mask.mif min $fixeldir/template/group_mask_intersection.mif -datatype bit -force

# Compute fixels on group template within the group mask
rm -rf  $fixeldir/template/fixel_mask/
fod2fixel -mask $fixeldir/template/group_mask_intersection.mif -fmls_peak_value 0.06 $fixeldir/template/fod_template.mif $fixeldir/template/fixel_mask -force

### Peform only on subjects that are processed for the first time
# Create a list of subjects to process
rm $scriptsdir/subjects_to_be_processed.txt
for sub in `ls -d ${qsirecdir}/sub* | grep -v html`; do
subname=`basename $sub`; 
echo $subname; 
if [ ! -f ${fixeldir}/subjects/$subname/ses-01/dwi/*ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif ] && [[ -d ${fixeldir}/subjects/$subname/ses-01 ]]; then 
	echo $sub >> $scriptsdir/subjects_to_be_processed.txt;
fi; 
done

# Warp subjects FOD images in to template space, without reorientation of FODs (performed later) [FOD taken from qsirec directory]
for_each $(cat $scriptsdir/subjects_to_be_processed.txt) : mrtransform ${qsirecdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz -warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif -reorient_fod no $fixeldir/subjects/NAME/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif -force


### Include all subjects from now on
# Segment subjects' FOD images, to estimate fixels and apparent fibers density
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented
for_each $fixeldir/subjects/* : fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented -afd fd.mif 

# Now reorient the fixels bsed on local transformation taken from previous warps
rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_desc-wmFixels
for_each $fixeldir/subjects/* : fixelreorient IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented IN/ses-01/dwi/NAME_to_template.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels

# match fixels from each individual to te template ones
rm $fixeldir/template/fd/index.mif
rm $fixeldir/template/fd/directions.mif
for_each $fixeldir/subjects/* : fixelcorrespondence IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels/fd.mif $fixeldir/template/fixel_mask $fixeldir/template/fd PRE.mif -force

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

