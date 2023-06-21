 function mask=tom_make_particle_mask(sub_mask,new_size,parameters)

%this function pasts a submask into mask with a bigger size
% 
% INPUT:    sub_mask: smaller mask that sould be pasted
%           new_size: size of the bigger mask
%           parameters: parameters(1):radius of the particle
%                       parameters(2):soothing of the sub_mask
%                       parameters(3):thres for submask
%  OUTPUT:  mask in sub 
%  
%
%  22/11/03 SN, 24/11/03 tested and bug fixed FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

 
part_radius=parameters(1);
smooth=parameters(2);
boarder=parameters(3);
%boarder

size_sub_maskX=size(sub_mask,1);
size_sub_maskY=size(sub_mask,2);

%sub_mask=tom_bandpass(sub_mask,1,((size_sub_maskX+size_sub_maskY)/2));
oo=ones(size_sub_maskX,size_sub_maskY);
mask1=tom_spheremask(oo,part_radius,smooth);
sub_mask=sub_mask.*mask1;
sub_mask=(sub_mask>boarder).*(sub_mask);

mask=zeros(new_size,new_size);
mask(((new_size/2)-(size_sub_maskX/2)):((new_size/2-1)+(size_sub_maskX/2)), ...
((new_size/2)-(size_sub_maskY/2)):((new_size/2-1)+(size_sub_maskY/2)))=sub_mask((1:size_sub_maskX),(1:size_sub_maskY));



