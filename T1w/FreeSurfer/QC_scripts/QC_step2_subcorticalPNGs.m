FS_directory='/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer';
QC_output_directory='/data/radv/radG/RAD/share/AMYPAD/derivatives/FreeSurfer/subcortical_QC';
ENIGMA_QC_folder='/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/FreeSurfer/ENIGMA_subcortical_QC';

addpath(ENIGMA_QC_folder)
a=dir(char(strcat(FS_directory,'/sub*')));
for x = 1:size(a,1) 
    [c,b,d]=fileparts(a(x,1).name); %b becomes the subject_name 
try 
    func_make_subcorticalFS_ENIGMA_QC(QC_output_directory, b, [FS_directory,'/', b, '/mri/orig.mgz'], [FS_directory,'/',b, '/mri/aparc+aseg.mgz']);
end 
display(['Done with subject: ', b,': ',num2str(x-2), ' of ', num2str(size(a,1)-2)]); 
end