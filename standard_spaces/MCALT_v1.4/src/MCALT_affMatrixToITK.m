function [status,filename]=MCALT_affMatrixToITK(affMat,filename)
% function [status,filename]=ADIR_affMatrixToITK(affMat,filename) 
%
% Given an affine matrix suitable for image registration, translate and
% output a file that is compatible with ITK (ANTs) conventions
% 
% By Gunter.Jeffrey@mayo.edu and Schwarz.Christopher@mayo.edu
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
%
status=0;
try
iAff=affMat; 
iAff=diag([-1 -1 1 1 ])*iAff*diag([-1 -1 1 1]);
catch
    status=1;
end

aff=iAff;
try
fid=fopen(filename,'w');
fprintf(fid,'#Insight Transform File V1.0\n#Transform 0\n');
fprintf(fid,'Transform: MatrixOffsetTransformBase_double_3_3\n');
fprintf(fid,'Parameters: %f %f %f %f %f %f %f %f %f %f %f %f\n', ...
    aff(1,1), aff(1,2), aff(1,3), aff(2,1), aff(2,2), aff(2,3),...
    aff(3,1), aff(3,2), aff(3,3), aff(1,4), aff(2,4), aff(3,4)...
    );

fprintf(fid,'FixedParameters: 0 0 0\n');
fclose(fid);
catch
    status=2;
    filename=[];
end
