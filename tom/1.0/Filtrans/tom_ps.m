function powers = tom_ps(im)
%TOM_PS calculates powerspektrum 
%
%   PS = tom_ps(IN)
%
%   Calculates the powerspectrum (squared amplitudes of the 
%   Fourier transform) of a multidimansional (2D or 3D) image
%   Zero frequency located in the middle!
%
% PARAMETERS
%   IN      input data (2D or 3D)
%   PS      power spectrum
%
% EXAMPLE
%   im = tom_emread('proteasome.em');
%   ps = tom_ps(im.Value);
%   tom_imagesc(log(ps));
%
% SEE ALSO
%   TOM_FOURIER, TOM_IFOURIER, FFTSHIFT, TOM_CTFFIT
%
%   FF
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom


[s1,s2,s3]=size(im);

if isequal(s3,1)
    powers = abs(fftshift(fft2(im)));
    powers = powers.^2;
elseif s3>1
    powers = abs(fftshift(fftn(im)));
    powers = powers.^2;
    
else
    error('Dimensions do not match');
end
