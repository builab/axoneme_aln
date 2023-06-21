function im = tom_shift_new(im, delta)
%TOM_SHIFT(IMAGE, [DELTA_X DELTA_Y DELTA_Z]) shifts an image by a vector
%   
%   im = tom_shift_new(im, delta)
%
%   The shift is performed in Fourier space, thus periodic 
%   boundaries are implicit. The shift vectors do not have to be
%   integer.
%   currently restricted to even dimensions of IMAGE
%
% INPUT
%   IM          1D, 2D or 3D array
%   DELTA       1D, 2D or 3D vector for shift
%
% OUTPUT
%   IM          shifted 1D, 2D or 3D array
%
% EXAMPLE
%   yyy = tom_sphere([64 64 64],10,1,[16 16 16]);
%   yyy = tom_shift(yyy, [1,2,3]);
%   tom_dspcub(yyy);
%
% SEE ALSO
%   TOM_MOVE, TOM_SHIFT_FFT
%
%   08/01/02 FF
%last change
%   01/16/04 FF
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom


[dimx,dimy,dimz]=size(im);
%c1 = double(int32(dimx/2));
%c2 = double(int32(dimy/2));
%MeshGrid with the sampling points of the image
[x,y,z]=ndgrid( -floor(size(im,1)/2):-floor(size(im,1)/2)+(size(im,1)-1),...
    -floor(size(im,2)/2):-floor(size(im,2)/2)+size(im,2)-1, ...
    -floor(size(im,3)/2):-floor(size(im,3)/2)+size(im,3)-1);
indx = find([dimx,dimy,dimz] == 1);
delta(indx)=0;
delta = delta./[dimx dimy dimz];
x = delta(1)*x + delta(2)*y + delta(3)*z; clear y; clear z;
im = fftshift(fftn(im));
im = real(ifftn(ifftshift(im.*exp(-2*pi*i*x))));