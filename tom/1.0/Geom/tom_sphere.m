function vol=tom_sphere(dims, radius,sigma,center);

% TOM_SPHERE creates volume with sphere of radius r around center
%
%   vol=tom_sphere(dims, radius,sigma,center);
%
%INPUT
%   dims         : dimensions (vector 2 or 3 by 1)
%   radius       : radius determining radius of sphere (or circle) 
%   sigma        : smoothing of mask; if entered mask will be smoothened;
%                  every voxel outside radius gets smoothened by a gaussian
%                  function exp(-((r-radius)/simga)^2)
%   center       : vector determining center of sphere (if omitted:
%                   default: Nx/2+1, Ny/2+1, Nz/2+1)
%
%OUTPUT
%   vol          : volume (2D or 3D)
%
%EXAMPLE
%   yyy = tom_sphere([64 64],4,10,[16 16 1]);
%   imagesc(yyy);
%
%25/02/04 FF
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom


error(nargchk(1,4,nargin))
if size(dims,2) == 2
    dims(3) = 1;
end;
if (nargin < 4)
    center=[floor(dims(1)/2)+1, floor(dims(2)/2)+1, floor(dims(3)/2)+1];
else
    if size(center,2) == 2
        center(3) = 1;
    end;
end;
[x,y,z]=ndgrid(0:dims(1)-1,0:dims(2)-1,0:dims(3)-1);
if (nargin < 2)
    radius = floor((min(min(dims(1),dims(2)),dims(2))-1)/2) ;
end;
x = sqrt((x+1-center(1)).^2+(y+1-center(2)).^2+(z+1-center(3)).^2);
ind = find(x>radius);
clear y z;
vol = ones(dims(1), dims(2), dims(3));

vol(ind) = 0;
if (nargin > 2) 
    if (sigma > 0)
        vol(ind) = exp(-((x(ind) -radius)/sigma).^2);
        ind = find(vol < exp(-2));
    end;
    vol(ind) = 0;
end;