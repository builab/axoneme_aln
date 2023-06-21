function tom_dspcub(a,var);

% DSPCUB(IM,MODE) Visualization of 3D image in a gallery
%
% USAGE
%   tom_dspcub(im,mode)
%
% PARAMETERS
%   IM      3D image
%   MODE    mode of presentation, can be 0 (=default), 1 or 2
%               0: xy-slices
%               1: yz-slices
%               2: xz-slices
%
%   Use as in EM 
%   AF
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom 
%
% last change 02/19/03 FF

if nargin==1
    var=2;
elseif nargin==2
    var=mod(var+2,3);
end
a=double(a);
a=tom_imadj(a);
[s1,s2,s3]=size(a);
a=shiftdim(a,var);
a=shiftdim(a,-1); a=shiftdim(a,2);
montage(a);

for kk=0:ceil(sqrt(s3))
    set(gca,'Ytick',[0:s1:kk*s1]);
    set(gca,'Xtick',[0:s2:kk*s2]);
end
set(gca,'XAxisLocation','top');
set(gca,'GridLineStyle','-');
set(gca,'XColor', [0.416 0.706 0.780]);
set(gca,'YColor', [0.416 0.706 0.780]);

axis on; grid on;

