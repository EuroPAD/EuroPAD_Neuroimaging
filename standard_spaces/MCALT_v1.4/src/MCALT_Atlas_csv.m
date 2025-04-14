function MCALT_Atlas_csv(imageFile,atlasFile,atlasLegend,outCSV,maskFile,excludeROIs)
% function MCALT_Atlas_csv(imageFile,atlasFile,atlasLegend,outCSV,maskFile,excludeROIs)
%
% Computes summary statistics of imageFile in each ROI in atlasFile
% 
% This file is part of the Mayo Clinic Adult Lifespan Template.
% https://www.nitrc.org/projects/mcalt/ .
%
% Copyright 2017-2020 Mayo Foundation for Medical Education and Research.
% This software is accepted by users "as is" and without warranties or
% guarantees of any kind. This software was designed to be used only for
% research purposes, and it is made freely available only for
% non-commercial research use. Contact the authors to obtain information on
% purchasing a separate license for commercial use. Clinical applications
% are not recommended, and this software has NOT been evaluated by the
% United States FDA for any clinical use.

hdr = spm_vol(imageFile);
vol = spm_read_vols(hdr);
pixdim = diag(hdr.mat);
voxel_volume = prod(pixdim);

atlasHdr = spm_vol(atlasFile);
atlas = spm_read_vols(atlasHdr);

legend = readtable(atlasLegend);

[~,fb,fe] = fileparts(imageFile);
[~,ab,ae] = fileparts(atlasFile);

doMask = 0;
if(exist('maskFile','var') && ~isempty(maskFile))
    maskHdr = spm_vol(maskFile);
    mask = spm_read_vols(maskHdr);
    [~,mb,me] = fileparts(maskFile);
    doMask = 1;
end

if(~exist('excludeROIs','var'))
    excludeROIs = [];
end

row = 1;
for i=1:size(legend,1)
    region_no = legend.Var1(i);
    region_name = legend.Var2{i};
    
    if(ismember(region_no,excludeROIs))
        continue;
    end

    if(~doMask)
        vmask = (atlas == region_no & vol>0);
        Voxels_Ignored_Mask = 0;
    else
        vmask = (atlas == region_no & vol>0 & mask >= 0.5);
        Voxels_Ignored_Mask = nnz(atlas == region_no & vol ~= 0 & mask < 0.5);
    end
    Voxels_Ignored_Zero = nnz(atlas == region_no & vol == 0);
    Total_Voxels = nnz(vmask);
    
    out(row).File = [fb fe];
    out(row).Atlas = [ab ae];
    if(doMask)
        out(row).Mask = [mb me];
    end
    out(row).Region_No = region_no;
    out(row).Region = region_name;
    out(row).Mean = mean(vol(vmask));
    out(row).Median = median(vol(vmask));
    out(row).Std_Dev = std(vol(vmask));
    out(row).Min = min(vol(vmask));
    out(row).Max = max(vol(vmask));
    out(row).Sum = sum(vol(vmask));
    out(row).Voxels_Ignored_Zero = Voxels_Ignored_Zero;
    if(doMask)
        out(row).Voxels_Ignored_Mask = Voxels_Ignored_Mask;
    end
    out(row).Total_Voxels = Total_Voxels;
    out(row).Voxel_Volume = voxel_volume;
    
    row = row + 1;
end

writetable(struct2table(out),outCSV);

end