function wedge=tom_wedge(image,angle)
%   wedge=tom_wedge(image,angle)
%
%   TOM_WEDGE produces a wedge shaped array. 
%   This array can be used as a window filter in Fourier space...
%
% PARAMETERS
%   image   input array - 3d 
%   angle   semi angle of missing wedge in deg
%   wedge   output - filter
%
% EXAMPLE
%   yyy = zeros(64,64,64);
%   wedge=tom_wedge(yyy,30);
%   tom_dspcub(wedge,1);
%   yyy(1,1,1) =1;
%   psf = real(tom_ifourier(ifftshift(fftshift(tom_fourier(yyy)).*wedge)));
%   figure;tom_dspcub(psf); % creates PSF of missing wedge
%
% SEE ALSO
%   TOM_FILTER, TOM_BANDPASS
%
%   FF 07/20/03
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom

% 25/07/2007
% Replace ind = find ...
% TODO Make origin the same as tom_rotate


warning off MATLAB:divideByZero;
angle = angle*pi/180;
[dimx, dimy, dimz] = size(image);
[x,y,z] = ndgrid(-floor(dimx/2):-floor(dimx/2)+dimx-1,-floor(dimy/2):-floor(dimy/2)+dimy-1,-floor(dimz/2):-floor(dimz/2)+dimz-1);
wedge = ones(dimx, dimy, dimz);
ind = tan(angle) > abs(x)./abs(z);
wedge(ind)=0;
