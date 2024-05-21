
%% Here's a simple MATLAB loop to loop through all the subjects and create PNG images for QC!!
%% Please note if you have a grid system to parallel process your images, you can also use a compiled version of the matlab code and run it across the grid. Contact us enigma@ini.usc.edu if you have questions on how.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%USER DEFINED INPUTS
%Choose "FS_directory" so that it selects only your subject folders that contain FS output
%"QC_output_directory" should be a folder you want to output your QC PNGS, we suggest just creating a folder within the FreeSurfer directory if you have writing permissions there!
%"ENIGMA_QC_folder" should be the path to the folder where you have downloaded the ENIGMA QC zip folder and unzipped. You may already be running this script from that folder, but just in case you are not, we will 'addpath' to that folder such that all functions can be used.
 
FS_directory='/data/radv/radG/RAD/share/AMYPAD-raw/derivatives/FreeSurfer';
QC_output_directory='/data/radv/radG/RAD/share/AMYPAD-raw/derivatives/FreeSurfer/QC';
ENIGMA_QC_folder='/home/radv/llorenzini/my-rdisk/RNG/Projects/ExploreASL/EPAD/scripts/multimodal_MRI_processing/FreeSurfer/ENIGMA_Cortical_QC_2.0';
%%%%%%%%%%%%%% /data/radv/radG/RAD/share/AMYPAD-raw/derivatives/FreeSurfer/%%%%%%%%%%%%%%%%%%%%%%%
cd(ENIGMA_QC_folder)
%%%%% some variable changes: %%%%%
% inDirectory: previously 'a'
% subjectID: previously 'b'
% i: previously 'x' 
 
% 'dir' will list all folders in the directory, so we need to start indexing from 3 as 1 and 2 will correspond to "." and ".." which correspond to the current directory and its parent directory 
 
inDirectory=dir(char(strcat(FS_directory,'/*')));
N=size(inDirectory,1);
 
%% if this errors out, change the N below to 3 and remove the semicolons ';' at the end of the 'T1mgz' and 'APSmgz' to check and make sure those paths exist!!
 
for i = 8:N  
    [c,subjectID,d]=fileparts(inDirectory(i,1).name); 
    try
    T1mgz=[FS_directory, '/', subjectID, '/mri/orig_nu.mgz'];
    APSmgz=[FS_directory,'/', subjectID, '/mri/aparc+aseg.mgz'];
        func_make_corticalpngs_ENIGMA_QC( QC_output_directory, subjectID, T1mgz ,APSmgz );
    end
    display(['Done with subject: ', subjectID, ': ', num2str(i-2), ' of ', num2str(N-2)]);
end
 
%%% Now you should be ready to view the website!! %%%%