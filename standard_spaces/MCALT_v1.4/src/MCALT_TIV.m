function [TIV, TTV] = MCALT_TIV(cFiles,outFile)
% function [TIV, TTV] = MCALT_TIV(cFiles,outFile)
%
% Creates MCALT TIV mask and returns TIV and TTV values.
% By Gunter.Jeffrey@mayo.edu and Schwarz.Christopher@mayo.edu
%
% Once the TIV mask is created, modifies (and overwrites) the input
% c1/c2/c3 so that values inside the TIV add up to 1.
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

%% Make TIV mask
thresh=0.5;
tissThresh=0.5;
numErode=3;

% add up all the probabilities
c1hdr = spm_vol(cFiles{1});
c1 = spm_read_vols(c1hdr);
c2hdr = spm_vol(cFiles{2});
c2 = spm_read_vols(c2hdr);
c3hdr = spm_vol(cFiles{3});
c3 = spm_read_vols(c3hdr);
ctiss = c1 + c2;
csum = c1 + c2 + c3;
pixdim = diag(c1hdr.mat);

% make a binarized version,  erode it, retain only the largest cluster,
% dilate that back out and select where it overlaps original input  -- this
% is an island remover.
ctmp=zeros(size(csum),'uint8');
ctmp(csum(:)>thresh)=1;
ctiss_bin=zeros(size(ctiss),'uint8');
ctiss_bin(ctiss(:)>tissThresh)=1;
% hold on to ctiss -- after we make our cleaned up TIV we'll mask this and
% add it up -- tissue must be inside TIV

se=strel(ones(3,3,3));
ctmp_erode=ctmp;
for i=1:numErode
    ctmp_erode=imerode(ctmp_erode,se);
end

CC=bwconncomp(ctmp_erode);
% CC now has a .pixelIdxList CA -- find the biggest one and keep it
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
ctmp_erode=zeros(size(ctmp_erode),'uint8');
ctmp_erode(CC.PixelIdxList{idx}) = 1;

for i=1:numErode+2
    ctmp_erode=imdilate(ctmp_erode,se);
end

ctmp=ctmp.*ctmp_erode;
ctmp=imfill(ctmp,'holes');

maskHdr = c1hdr;
maskHdr.fname = outFile;
spm_write_vol(maskHdr,ctmp);

%% Calculate TIV
TIV=sum(ctmp(:)>0) .* prod(pixdim(1:3));
TTV=sum(ctiss_bin(:) .* ctmp(:)) .* prod(pixdim(1:3));

%% Clean up segmentations based on TIV
tivHdr=spm_vol(outFile);
tivMask = spm_read_vols(tivHdr);
tivMask_dil=imdilate(tivMask,strel(makeSphereInMM(pixdim,15)));
outside=find(~tivMask_dil(:));
inside=find(tivMask(:));

c1(outside)=0;
c2(outside)=0;
c3(outside)=0;

% outside is taken care of.  Now make we make sure everything inside the
% original TIV has g+w+c=1
c1(inside)=c1(inside)./csum(inside);
c1(isnan(c1(:)))=0;
c2(inside)=c2(inside)./csum(inside);
c2(isnan(c2(:)))=0;
c3(inside)=c3(inside)./csum(inside);
c3(isnan(c1(:)))=0;

% save
c1hdr.dt(1) = 16;
c2hdr.dt(1) = 16;
c3hdr.dt(1) = 16;
spm_write_vol(c1hdr,c1);
spm_write_vol(c2hdr,c2);
spm_write_vol(c3hdr,c3);

end

function T=makeSphereInMM(pixdim,radius)

templateRadius=radius;
xvals=-templateRadius:pixdim(1):templateRadius;
yvals=-templateRadius:pixdim(2):templateRadius;
zvals=-templateRadius:pixdim(3):templateRadius;

if ~mod(length(xvals),2)
    xvals=-templateRadius-pixdim(1)/2:pixdim(1):templateRadius+pixdim(1)/2;
    
end

if ~mod(length(yvals),2)
    yvals=-templateRadius-pixdim(2)/2:pixdim(2):templateRadius+pixdim(2)/2;
    
end

if ~mod(length(zvals),2)
    zvals=-templateRadius-pixdim(3)/2:pixdim(3):templateRadius+pixdim(3)/2;
end

xvals=xvals-mean(xvals);
yvals=yvals-mean(yvals);
zvals=zvals-mean(zvals);
[x,y,z]=ndgrid(xvals,yvals,zvals);
T = sqrt ( x.^2 + y.^2 + z.^2 ) < radius;

end
