## HERE we need to copy (link (ln -s)) subjects folder from qsirecon, with the same structure, but only the files that will be used in this analysis, i.e. fods // tracks // brain masks
qsirecdir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/qsirecon #original qsirecon output
qsiprepdir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/qsiprep #original qsiprep output
fixeldir=/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/derivatives/DTI_fixels #outpt fixel directory

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


## Create links of subjects files needed for the analysis (stored in qsirecon folders) ##
#### PROBLEM : APPARENTLY WE CANNOT DO LINKS IN THE R-DISK, COPY ALL OR JUST USE DERIVATIVES
### PROBABLY NEED THIS PART TO ONLY CREATE THE FOLDER STRUCTURE
## SEE BELOW FOR SOLUTION
for sub in `ls -d ${qsirecdir}/sub* | grep -v html | head -10`; do 

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

done; 

done



### SOLUTION 1 ONLY USE THE ORIGINAL DATA AND STORE THE OUTPUT IN DTI_FIXELS (template part should be done separately)

#if [[ -f 
### Template Cretion :  NEEDS TO BE CHANGED 
for_each `ls -d ${qsirecdir}/sub* | grep -v html | head -10` : cp IN/ses-01/dwi/NAME_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz $fixeldir/FOD_images 

for_each  `ls -d ${qsirecdir}/sub* | grep -v html | head -10` : cp ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-brain_mask.nii.gz $fixeldir/FOD_images  

population_template FOD_images -mask_dir mask_images template/fod_template.mif

# Compute the transformation (mrregister) of the WM FOD to the group template 
for_each `ls -d ${qsirecdir}/sub* | grep -v html | head -10` : mrregister IN/ses-01/dwi/NAME_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz -mask1 ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-brain_mask.nii.gz $fixeldir/template/fod_template.mif -nl_warp $fixeldir/subjects/NAME/ses-01/dwi/NAME_to_template.mif $fixeldir/subjects/NAME/ses-01/dwi/template_to_NAME.mif 

# Apply the computed transformation to the masks
for_each $fixeldir/subjects/* : mrtransform ${qsiprepdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-brain_mask.nii.gz -warp IN/ses-01/dwi/NAME_to_template.mif -interp nearest IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-brain_mask.mif

# take the intersection of the masks and create a group mask
mrmath $fixeldir/subjects/*/ses-01/dwi/sub*space-FODtemplate_desc-brain_mask.mif min $fixeldir/template/group_mask_intersection.mif -datatype bit -force

# Compute fixels on group template within the group mask
rm -rf  $fixeldir/template/fixel_mask/
fod2fixel -mask $fixeldir/template/group_mask_intersection.mif -fmls_peak_value 0.06 $fixeldir/template/fod_template.mif $fixeldir/template/fixel_mask -force

# Warp subjects FOD images in to template space, without reorientation of FODs (performed later) [ FOD taken from qsirec directory]
for_each $fixeldir/subjects/* : mrtransform ${qsirecdir}/NAME/ses-01/dwi/NAME_ses-01_space-T1w_desc-preproc_desc-wmFODmtnormed_ss3tcsd.mif.gz -warp IN/ses-01/dwi/NAME_to_template.mif -reorient_fod no IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif 

# Segment subjects' FOD images, to estimate fixels and apparent fibers density
for_each $fixeldir/subjects/* : fod2fixel -mask $fixeldir/template/group_mask_intersection.mif  IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFODmtnormed_ss3tcsd_not_reoriented.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented -afd fd.mif

# Now reorient the fixels bsed on local transformation taken from previous warps
for_each $fixeldir/subjects/* : fixelreorient IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented IN/ses-01/dwi/NAME_to_template.mif IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels

rm -rf $fixeldir/subjects/sub*/ses-01/dwi/sub*_ses-01_space-FODtemplate_desc-wmFixels_not_reoriented # remove non reoriented

# match fixels from each individual to te template ones
for_each $fixeldir/subjects/* : fixelcorrespondence IN/ses-01/dwi/NAME_ses-01_space-FODtemplate_desc-wmFixels/fd.mif $fixeldir/template/fixel_mask $fixeldir/template/fd PRE.mif

# Compute Fibre crossection (FC) from the warps
for_each $fixeldir/subjects/* : warp2metric IN/ses-01/dwi/NAME_to_template.mif -fc $fixeldir/template/fixel_mask $fixeldir/template/fc PRE.mif

# Log FC
mkdir $fixeldir/template/log_fc
cp $fixeldir/template/fc/index.mif $fixeldir/template/fc/directions.mif $fixeldir/template/log_fc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fc/PRE.mif -log $fixeldir/template/log_fc/PRE.mif

# Compute FDC
mkdir $fixeldir/template/fdc
cp $fixeldir/template/fc/index.mif $fixeldir/template/fdc
cp $fixeldir/template/fc/directions.mif $fixeldir/template/fdc
for_each $fixeldir/subjects/* : mrcalc $fixeldir/template/fd/PRE.mif $fixeldir/template/fc/PRE.mif -mult $fixeldir/template/fdc/PRE.mif

# run tractography on the template 
cd $fixeldir/template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 fod_template.mif -seed_image group_mask_intersection.mif -mask group_mask_intersection.mif -select 20000000 -cutoff 0.06 tracks_20_million.tck

tcksift tracks_20_million.tck fod_template.mif tracks_2_million_sift.tck -term_number 2000000 # filter

# Fixel Connectivity
fixelconnectivity fixel_mask/ tracks_2_million_sift.tck matrix/

# Fixel filtering (smoothing)
fixelfilter fd smooth fd_smooth -matrix matrix/
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/
fixelfilter fdc smooth fdc_smooth -matrix matrix/


