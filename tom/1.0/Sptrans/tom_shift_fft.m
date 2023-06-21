function fim = tom_shift_fft(fim, delta)
%Shifts an image by a vector
%   
%SYNTAX
%fim = tom_shift_fft(fim, delta)
%
%DESCRIPTION
%An array FIM is shifted in Fourier space - the array FIM has to be
%complex (~ in Fourier space. currently restricted to even dimensions of
%IMAGE
%
%
% INPUT
%   IM          1D, 2D array in Fourier space
%   DELTA       1D, 2D vector for shift
%
% OUTPUT
%   IM          shifted 1D, 2D array in Fourier space
%
%EXAMPLE
%xxx= zeros(128,128);xxx(1,1,1)=1;
%tom_imagesc(xxx);
%xxx=tom_fourier(xxx);xxx=tom_shift_fft(xxx,[1.5,1.5]);
%xxx=real(tom_ifourier(xxx));figure;imagesc(xxx')
%
%SEE ALSO
%TOM_MOVE, TOM_SHIFT
%
%Copyright (c) 2005
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 19/02/04 FF
%


[dimx,dimy,dimz]=size(fim);
%c1 = double(int32(dimx/2));
%c2 = double(int32(dimy/2));
%MeshGrid with the sampling points of the image
[x,y,z]=ndgrid( -floor(size(fim,1)/2):-floor(size(fim,1)/2)+(size(fim,1)-1),...
    -floor(size(fim,2)/2):-floor(size(fim,2)/2)+size(fim,2)-1,...
    -floor(size(fim,3)/2):-floor(size(fim,3)/2)+(size(fim,3)-1));
indx = find([dimx,dimy,dimz] == 1);
delta(indx)=0;
delta = delta./[dimx dimy dimz];
x = delta(1)*x + delta(2)*y + delta(3)*z; clear y; clear z;
fim = fftshift(fim);
fim = ifftshift(fim.*exp(-2*pi*i*x));