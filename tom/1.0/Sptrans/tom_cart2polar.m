function pol = tom_cart2polar(I)
% TOM_CART2POLAR transforms 2D-images from cartesian to polar coordinates
%
%   pol = tom_cart2polar(I)
%
%   A 2D image I given in cartesina coordinates is sampled in polar coordinates 
%   R, PHI using bilinear interpolation. The input image I is assumed to be of 
%   equal dimensions NX and NY. The ouput POL(R,PHI) has dimensions NR=NX/2, 
%   NPHI=4*NR.
%   
%   I       2 dim array
%   POL     2 dim array in polar coordinates
%
% EXAMPLE
%   cart = zeros(32,32);
%   cart(8,8) = 1;
%   cart = tom_symref2d(cart,4);
%   pol = tom_cart2polar(cart);
%   imagesc(pol');
%
% SEE ALSO
%   TOM_POLAR2CART, TOM_CART2SPH, TOM_SPH2CART
%
%   FF 08/17/03
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

nx = size(I,1);ny = size(I,2);nz = size(I,3);
if nz > 1
    error(' use for tom_cart2sph for 3D arrays!')
end;
nradius = max(nx,ny)/2;
nphi = 4*nradius;
[r phi] = ndgrid(0:nradius-1,0:2*pi/nphi:2*pi-2*pi/nphi);
% polar coordinates in cartesian space
%eps = 10^(-12);%added due to numerical trouble with floor
eps = 0;
px = r.*cos(phi)+nradius+1+eps;
py = r.*sin(phi)+nradius+1+eps;
clear r phi ; 
%%%%%%%%%%%%%% bilinear interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate levers
tx = px-floor(px);
ty = py-floor(py);
%perform interpolation
%   check for undefined indexes
%mxx = max(max(floor(px+1)));
%if  mxx > nx
%    I(mxx,ny) =0;
%    nx = mxx;
%end;
%mxy = max(max(floor(py+1)));
%if mxy > ny
%    I(nx,mxy)=0;
%    ny = mxy;
%end;    
%pol = (1-tx).*(1-ty).*I(floor(px)+nx*(floor(py)-1)) + ...
%    (tx).*(1-ty).*I(floor(px+1)+nx*(floor(py)-1)) + ...
%    (1-tx).*(ty).*I(floor(px)+nx*(floor(py+1)-1)) + ...
%    (tx).*(ty).*I(floor(px+1)+nx*(floor(py+1)-1));
pol = (1-tx).*(1-ty).*I(floor(px)+nx*(floor(py)-1)) + ...
    (tx).*(1-ty).*I(ceil(px)+nx*(floor(py)-1)) + ...
    (1-tx).*(ty).*I(floor(px)+nx*(ceil(py)-1)) + ...
    (tx).*(ty).*I(ceil(px)+nx*(ceil(py)-1));