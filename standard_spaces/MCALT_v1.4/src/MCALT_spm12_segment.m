function MCALT_spm12_segment(inFile,outDir)
% This file contains matlab source code to perform SPM12 unified
% segmentation (tissue-class probabilities, bias correction, and
% normalization to MCALT space) using MCALT tissue priors and our modified
% segmentation method/settings that are optimized for older adults age 30+.
%
% If Advanced Normalization Tools (ANTS) is installed, this function will
% also transform atlases to the input image space using ANTs and calculate
% per-region GM/tissue volumes and TIV as .csv files.
%
% This function re-implements the SPM12 T1-weighted processing pipeline
% used in Dr. Jack's Aging and Dementia Research Lab at Mayo Clinic. Output
% volumes are not exactly identical but can be directly compared with those
% computed in-house.
%
% Regional gray matter volumes measured using this segmentation method have
% larger AUROC values than standard SPM12 pipelines when comparing between
% matched groups of amyloid-positive cognitively-impaired and
% amyloid-negative cognitively-unimpaired subjects. See
% MCALT_Segmentation_Poster.pdf for more information.
%
% Results are saved in the chosen output directory. The primary changes vs.
% standard SPM12 Segment settings are:
%
%   1. Use of MCALT tissue priors rather than default SPM12. These better
%      match the adult population across the lifespan aged 30+. 
%
%   2. Use of two Gaussians to model WM signal intensity, rather than the
%      default of 1. This better allows for the existence of hypointense
%      WM. Naively changing this setting to two Gaussians causes failures
%      in scans with very large ventricles, where some CSF is called WM. To
%      avoid this failure case, we first segment the image using one WM
%      gaussian, then add a second WM gaussian with mean intensity < the
%      original, then resume the segmentation from this point with two WM
%      Gaussians.
% 
%   3. Reduced penalty for stronger nonlinear deformations. This allows
%      segmentation of images with a larger degree of pathology.
%
%   4. Atlas normalization and calcualation of regional tissue volumes
%      using ANTs tools. 
%
% This function requires that SPM12 has been installed, and that the
% spm_preproc_run.m included with SPM12 has been patched or edited using
% the included patch_spm_preproc_run.patch with the unix/linux 'patch'
% utility. MCALT and its subdirectories should be added to your matlab path
% using addpath(genpath('Your_MCALT_Path')). Atlas functionality requires
% that ANTs is installed and added to your system path. 
%
% This file is part of the Mayo Clinic Adult Lifespan Template.
% https://www.nitrc.org/projects/mcalt/ .
%
% If you use the segmentation code, please cite the following: 
% Christopher G. Schwarz, Jeffrey L. Gunter, Chadwick P. Ward, Kejal
% Kantarci, Prashanthi Vemuri, Matthew L. Senjem, Ronald C. Petersen, David
% S. Knopman, Clifford R. Jack Jr. "Methods to Improve SPM12 Tissue
% Segmentations of Older Adult Brains". In Proc: Alzheimer's Association
% International Conference, 2018.
%
% Copyright 2017-2020 Mayo Foundation for Medical Education and Research.
% This software is accepted by users "as is" and without warranties or
% guarantees of any kind. This software was designed to be used only for
% research purposes, and it is made freely available only for
% non-commercial research use. Contact the authors to obtain information on
% purchasing a separate license for commercial use. Clinical applications
% are not recommended, and this software has NOT been evaluated by the
% United States FDA for any clinical use.
%
% See LICENSE.txt and README.txt for more information.


%% Modify these paths to necessary inputs if needed
MCALT_T1File = which('MCALT_T1.nii');
MCALT_TPMFile = which('MCALT_tpm.nii');
[MCALT_dir,~,~] = fileparts(MCALT_T1File);

%% preamble
startTime = tic;

owd=pwd;
cleanupVar = onCleanup(@()cd(owd));

if ~exist('inFile','var') || isempty(inFile)
    help(mfilename);
    return;
end

if(isstring(inFile))
    inFile = char(inFile);
end

[fpath,fbase,fext]=fileparts(inFile);

if ~exist('outDir','var') || isempty(outDir)
    outDir=[fpath filesep 'seg12'];
end

if(isstring(outDir))
    outDir = char(outDir);
end

if ~exist(outDir,'dir')
    mkdir(outDir);
end

doAtlas = 1;
[stat,~]=system('which ANTS');
if(stat)
    disp('Could not locate ANTS in your system path; will not proceed with atlas steps after segmentation');
    doAtlas = 0;
end
[stat,~]=system('which antsApplyTransforms');
if(stat)
    disp('Could not locate antsApplyTransforms in your system path; will not proceed with atlas steps after segmentation');
    doAtlas = 0;
end

copyfile(inFile,outDir);
chdir(outDir);

if( ~isfile( ['c1' fbase fext] ) )
    
    %% prepare job struct
    % 'MCALT_spm12_segment_job.m' is required in the matlab path. Some settings
    % and modifications are performed in this file.
    jobFile={which('MCALT_spm12_segment_job.m')};
    
    % now load the matlabbatch struct from jobFile
    [~,fb]=fileparts(jobFile{1});
    clear matlabbatch;
    eval(fb);
    if ~exist('matlabbatch','var')
        error('MCALT_spm12_segment:noMatlabBatch','cannot get matlabbatch struct from %s',jobFile{1});
    end
    
    % Set the input image
    matlabbatch{1}.spm.spatial.preproc.channel.vols = {[fbase fext ',1']};
    
    % Set the TPM
    for i=1:length(matlabbatch{1}.spm.spatial.preproc.tissue)
        matlabbatch{1}.spm.spatial.preproc.tissue(i).tpm{1}=[MCALT_TPMFile ',' num2str(i)];
    end
    
    %% Run segmentation round 1 with 1 WM Gaussian
    % Initialize SPM
    spm('defaults', 'PET');
    
    % Use spm_coreg to between the input T1-weighted scan and the T1-weighted
    % template to initialize registration, rather than using the default method
    % inside unified seg. We have found this to be more robust.
    disp('Initializing subject->template registration with spm_coreg');
    regInit=spm_coreg(matlabbatch{1}.spm.spatial.preproc.channel.vols{1},MCALT_T1File);
    segAffine=spm_matrix(regInit);
    matlabbatch{1}.spm.spatial.preproc.warp.Affine=segAffine;
    
    disp('Running initial segmentation with 1 WM Gaussian');
    runOut=spm_preproc_run(matlabbatch{1}.spm.spatial.preproc,'run');
    
    %% Add a second Gaussian to the parameters
    % Add a second WM Gaussian to the seg8 struct. Make it lower intensity
    % (multiply existing mean by 0.94) so we can try to capture the WMH
    % class.
    disp('Continuing optimization with a second WM Gaussian added')
    seg8_add_Gaussian(runOut.param{1},2,0.94);
    
    % Add second WM Gaussian to the SPM job struct
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
    
    %% Set to write output images this time around
    % We chose NOT to do this in round one because we would have overwritten
    % them anyway in round two.
    %
    % You can disable any of these that you don't want, to save time and disk
    % space Any of them can be generated later from the saved *_seg8.mat,
    % without re-running the full segmentation, using spm_preproc_write8()
    
    % Set whether to write bias-corrected (M*)
    matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
    
    % Set whether to write segmentations
    % GM
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0]; % native-space (c1*), resliced to template (rc1*)
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1]; % warped to template (wc1*), modulated warped to template (mwc1*)
    % WM
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0]; % native-space (c2*), resliced to template (rc2*)
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1]; % warped to template (wc2*), modulated warped to template (mwc2*)
    % CSF
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0]; % native-space (c3*), resliced to template (rc3*)
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1]; % warped to template (wc3*), modulated warped to template (mwc3*)
    % Dura/Skull/Soft tissue
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0]; % native-space (c4*), resliced to template (rc4*)
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0]; % warped to template (wc4*), modulated warped to template (mwc4*)
    % Dura/Skull/Soft tissue
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0]; % native-space (c5*), resliced to template (rc5*)
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0]; % warped to template (wc5*), modulated warped to template (mwc5*)
    % Air
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0]; % native-space (c6*), resliced to template (rc6*)
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0]; % warped to template (wc6*), modulated warped to template (mwc6*)
    
    % Set whether to write warps.
    %
    % Note that MCALT recommends to instead use an ANTs SyN warp between the
    % bias-corrected (M*) subject T1-weighted scan and MCALT_T1 in order to
    % propogate atlas regions to subject space. We do, however, recommend using
    % these SPM warps for VBM
    matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1]; % forward (y_*), inverse (iy_*)
    
    %% Run segmentation round 2 with 2 WM Gaussians
    % Requires 'resume' option to have been added to spm_preproc_run via the
    % included patch
    runOut=spm_preproc_run(matlabbatch{1}.spm.spatial.preproc,'resume');
    
    %% Save the output seg8 file
    % Change the input file location to its original location, rather than in
    % the output directory
    seg8File=runOut.param{1};
    seg8=load(seg8File);
    seg8.image(1).fname=inFile;
    save(seg8File,'-struct','seg8');

else
    disp(['Found existing SPM segmentation files in the output directory. We will skip this step.']);
end

%% Calculate ANTS warp
if( doAtlas == 0 )
    disp('Skipping atlas steps because doAtlas is disabled (ANTS was probably not found in your system path');
    return;
end

oBase = [ fbase '_to_MCALT_' ];

if( ~isfile([oBase 'InverseWarp.nii.gz']) )
    % Initialize the ANTs warp with SPM's affine matrix. This is more robust
    % than using ANTs' internally.
    MCALT_affMatrixToITK(inv(seg8.Affine),[oBase 'SPMAffine.txt']);
    
    disp('Running ANTs warp to MCALT space. This will take a while');
    antsCmd='ANTS 3 '; % Assuming a 3D input
    antsCmd=[antsCmd ' -m CC[' MCALT_T1File ',m' fbase fext]; % use input after bias correction from SPM
    antsCmd=[antsCmd ',1,5]']; % default
    antsCmd=[antsCmd ' -t SyN[0.25]']; % default
    antsCmd=[antsCmd ' -r Gauss[3,0]'];  % default
    antsCmd=[antsCmd ' -a ' oBase 'SPMAffine.txt'];
    antsCmd=[antsCmd ' -x ' strrep(MCALT_T1File,'_T1.nii','_regmask.nii')];
    antsCmd=[antsCmd ' -o ' oBase];
    antsCmd=[antsCmd ' -i 30x30x50x50x180x180 ']; % more high-res iterations than the default
    [status,res]=system(antsCmd);
    if(status>0); error([antsCmd 'failed with output: ' res]); end
else
    disp(['Found existing warp file in output directory: ' [oBase 'InverseWarp.nii.gz'] ' We will use it and skip this step.']);
end

%% Apply ANTs warps
disp('Resampling atlases into native space');

% ADIR122
antsCmd = ['antsApplyTransforms -i ' [ MCALT_dir filesep 'atlas' filesep 'MCALT_ADIR122.nii' ] ' -o ' [ fbase '_MCALT_ADIR122.nii' ] ' -r ' [fbase fext] ' -n GenericLabel ' ' -t [' oBase 'Affine.txt,1]' ' -t ' [oBase 'InverseWarp.nii.gz' ] ];
[status,res]=system(antsCmd);
if(status>0); error([antsCmd 'failed with output: ' res]); end

% ADIR42
antsCmd = ['antsApplyTransforms -i ' [ MCALT_dir filesep 'atlas' filesep 'MCALT_ADIR42.nii' ] ' -o ' [ fbase '_MCALT_ADIR42.nii' ] ' -r ' [fbase fext] ' -n GenericLabel ' ' -t [' oBase 'Affine.txt,1]' ' -t ' [oBase 'InverseWarp.nii.gz' ] ];
[status,res]=system(antsCmd);
if(status>0); error([antsCmd 'failed with output: ' res]); end

% ADIR_Lobar
antsCmd = ['antsApplyTransforms -i ' [ MCALT_dir filesep 'atlas' filesep 'MCALT_Lobar.nii' ] ' -o ' [ fbase '_MCALT_Lobar.nii' ] ' -r ' [fbase fext] ' -n GenericLabel ' ' -t [' oBase 'Affine.txt,1]' ' -t ' [oBase 'InverseWarp.nii.gz' ] ];
[status,res]=system(antsCmd);
if(status>0); error([antsCmd 'failed with output: ' res]); end

% MCALT_T1 (for visual QC purposes)
antsCmd = ['antsApplyTransforms -i ' MCALT_T1File ' -o ' [ fbase '_MCALT_T1.nii' ] ' -r ' [fbase fext] ' -n BSpline ' ' -t [' oBase 'Affine.txt,1]' ' -t ' [oBase 'InverseWarp.nii.gz' ] ];
[status,res]=system(antsCmd);
if(status>0); error([antsCmd 'failed with output: ' res]); end

% MCALT_MTL_nogo (used for atlas-ing to remove non-GM near MTL)
antsCmd = ['antsApplyTransforms -i ' [ MCALT_dir filesep 'atlas' filesep 'MCALT_MTL_nogo.nii' ] ' -o ' [ fbase '_MCALT_MTL_nogo.nii' ] ' -r ' [fbase fext] ' -n Linear ' ' -t [' oBase 'Affine.txt,1]' ' -t ' [oBase 'InverseWarp.nii.gz' ] ];
[status,res]=system(antsCmd);
if(status>0); error([antsCmd 'failed with output: ' res]); end

%% Create masks
disp('Saving tissue masks');
% mask c1 (GM) with nogo
hdr = spm_vol([ fbase '_MCALT_MTL_nogo.nii' ]);
nogo = spm_read_vols(hdr);
hdr = spm_vol(['c1' fbase fext]);
c1 = spm_read_vols(hdr);
c1(nogo>0.5)=0;
hdr.fname = [ 'c1' fbase '_masked.nii' ];
spm_write_vol(hdr,c1);
clear nogo c1

% Create tissue masks
% Determine argmax class at each location
cFiles = {['c1' fbase fext],['c2' fbase fext],['c3' fbase fext]};
for c=1:numel(cFiles)
    cIndex = str2double(cFiles{c}(2:2));
    if(cIndex == 1)
        cFiles{c} = strrep(cFiles{c},fext,'_masked.nii');
    end
    hdr = spm_vol(cFiles{c});
    cArr(:,:,:,cIndex) = spm_read_vols(hdr);
end

cTiss = ['cTissue' fbase fext];
hdr.fname = cTiss;
hdr.dt(1) = 16;
tiss = cArr(:,:,:,1) + cArr(:,:,:,2);
spm_write_vol(hdr,tiss);

cSum = sum(cArr,4);
[~,cMax] = max(cArr,[],4);
cMax(cSum==0)=0;
% Save argmax
hdr.fname = [ 'cMax' fbase fext ];
hdr.dt(1) = 16;
spm_write_vol(hdr,cMax);
% Save masks
hdr.dt(1) = 2;
GM = (cMax==1);
hdr.fname = [ fbase '_MASK_GM' fext ];
spm_write_vol(hdr,GM);
WM = (cMax==2);
hdr.fname = [ fbase '_MASK_WM' fext ];
spm_write_vol(hdr,WM);
GMWM = (cMax==1 | cMax==2);
hdr.fname = [ fbase '_MASK_GMWM' fext ];
spm_write_vol(hdr,GMWM);

%% Make TIV mask, calculate TIV, and clean up segmentations based on TIV
disp('Creating TIV mask and calculating TIV');
TIVfile = [fbase '_TIV.nii'];
[TIV, TTV] = MCALT_TIV(cFiles,TIVfile);
disp(['Saved: ' TIVfile]);
disp(['TIV: ' num2str(TIV)]);
disp(['TTV: ' num2str(TTV)]);

%% Save CSV files
disp('Saving CSV files');
TIV_t = struct();
TIV_t.File = [fbase fext];
TIV_t.TIV = TIV;
TIV_t.TTV = TTV;
writetable(struct2table(TIV_t),[fbase '_TIV.csv']);

MCALT_Atlas_csv(cFiles{1},[ fbase '_MCALT_ADIR122.nii' ],which('MCALT_ADIR122.txt'),[ fbase '_GMVol_ADIR122.csv'],TIVfile,[0 35:36 39:40 109:116 117:118]);
disp(['Wrote: ' [ fbase '_GMVol_ADIR122.csv']]);

MCALT_Atlas_csv(cTiss,[ fbase '_MCALT_ADIR122.nii' ],which('MCALT_ADIR122.txt'),[ fbase '_TissueVol_ADIR122.csv'],TIVfile,[0 35:36 39:40]);
disp(['Wrote: ' [ fbase '_TissueVol_ADIR122.csv']]);

MCALT_Atlas_csv(cFiles{1},[ fbase '_MCALT_ADIR42.nii' ],which('MCALT_ADIR42.txt'),[ fbase '_GMVol_ADIR42.csv'],TIVfile,[36 45]);
disp(['Wrote: ' [ fbase '_GMVol_ADIR122.csv']]);

MCALT_Atlas_csv(cTiss,[ fbase '_MCALT_ADIR42.nii' ],which('MCALT_ADIR42.txt'),[ fbase '_TissueVol_ADIR42.csv'],TIVfile,[]);
disp(['Wrote: ' [ fbase '_TissueVol_ADIR122.csv']]);

MCALT_Atlas_csv(cFiles{1},[ fbase '_MCALT_Lobar.nii' ],which('MCALT_Lobar.txt'),[ fbase '_GMVol_Lobar.csv'],TIVfile,[5 6 21]);
disp(['Wrote: ' [ fbase '_GMVol_Lobar.csv']]);

MCALT_Atlas_csv(cFiles{2},[ fbase '_MCALT_Lobar.nii' ],which('MCALT_Lobar.txt'),[ fbase '_WMVol_Lobar.csv'],TIVfile);
disp(['Wrote: ' [ fbase '_WMVol_Lobar.csv']]);

MCALT_Atlas_csv(cTiss,[ fbase '_MCALT_Lobar.nii' ],which('MCALT_Lobar.txt'),[ fbase '_TissueVol_Lobar.csv'],TIVfile);
disp(['Wrote: ' [ fbase '_TissueVol_Lobar.csv']]);

%% Finish
chdir(owd);
disp(['MCALT_spm12_segment finished in: ' num2str(toc(startTime)) ' seconds']);
end

function seg8_add_Gaussian(seg8File, classToAdd, optMeanMultiplier)
    % Add a second Gaussian to the seg8 structure
    seg8=load(seg8File);
    out = seg8;
    lastIndex = find(seg8.lkp==classToAdd,1,'last');
    % lkp is the index of which Gaussians are which tissue class. Add
    % another one for classToAdd after the last existing one
    out.lkp = [ seg8.lkp(1:lastIndex),classToAdd,seg8.lkp(lastIndex+1:end) ];
    
    oldClassIDs = find(seg8.lkp == classToAdd);
    newClassIDs = find(out.lkp == classToAdd);
    newClassCount = length(newClassIDs);
    
    % mg is the mixing proportions for the Gaussians within each class
    % Set those for each of the classToAdd gaussians to 1/(total #)
    out.mg = [ seg8.mg(1:lastIndex);1/newClassCount;seg8.mg(lastIndex+1:end) ];
    out.mg(newClassIDs) = 1/newClassCount;
    
    % mn is the means of each Gaussian. 
    if exist('optMeanMultiplier','var') && ~isempty(optMeanMultiplier)
        if(optMeanMultiplier > 1)
            % set the new Gaussian to max(oldClassIDs)*optMeanMultiplier
            out.mn = [ seg8.mn(1:lastIndex),max(seg8.mn(oldClassIDs))*optMeanMultiplier,seg8.mn(lastIndex+1:end) ];
        elseif(optMeanMultiplier < 1)
            % set the new Gaussian to min(oldClassIDs)*optMeanMultiplier
            out.mn = [ seg8.mn(1:lastIndex),min(seg8.mn(oldClassIDs))*optMeanMultiplier,seg8.mn(lastIndex+1:end) ];
        else
            % set the new Gaussian to the mean of the current ones
            out.mn = [ seg8.mn(1:lastIndex),mean(seg8.mn(oldClassIDs)),seg8.mn(lastIndex+1:end) ];
        end
    else % try to pick sane defaults: +/- 5% for the 1->2 case, set to the mean for >2
        if(newClassCount == 2)
            % Set the two Gaussians to +- 5% of the original
            out.mn = [ seg8.mn(1:lastIndex-1),seg8.mn(lastIndex) * 0.95,seg8.mn(lastIndex) * 1.05,seg8.mn(lastIndex+1:end) ];
        else
            % Set the new Gaussian's mean to the mean of the current ones
            out.mn = [ seg8.mn(1:lastIndex),mean(seg8.mn(oldClassIDs)),seg8.mn(lastIndex+1:end) ];
        end
    end
    % vr is the covariances of each Gaussian. This is less intuitive so
    % we're just going to set the new one to match that of the old one and
    % let things continue from there
    out = rmfield(out,'vr');
    out.vr(1,1,:) = [ squeeze(seg8.vr(1:lastIndex));squeeze(seg8.vr(lastIndex));squeeze(seg8.vr(lastIndex+1:end)) ];
    % save out modified seg8, which will then be picked up by the next
    % 'resume' iteration
    save( seg8File, '-struct', 'out' );

end
