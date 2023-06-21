function image = tom_smooth(image, border, sigma, flag)
%TOM_SMOOTH performs smoothing of borders
%   TOM_SMOOTH(IMAGE, BORDER, SIGMA, FLAG) performs smoothing of borders for 1D, 2D, and 3D data.
%   edges are set to mean value of all border pixels, values get damped by
%   a gaussian function F(n) = (Exp(-2*n**2/SIGMA**2)) - Exp(-2)/(1-Exp(-2)).
%
%PARAMETERS
% Input
%   IMAGE    : 1,2 or 3D data
%   BORDER   : width of border
%   SIGMA    : steepness of smoothing function (default: BORDER)
%   FLAGS    :  - 'zero' set values to Zero at edges
%Output
%   OUT      : image smoothened 
%
%EXAMPLE
%   rand('state',sum(100*clock));
%   image = rand(128, 128);
%   out = tom_smooth(image, 10, 8, 'zero');
%   imagesc(out);
%
%   In the example a random image is smoothened, values are set zero at border.
%
%   07/27/02 FF
%   
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom



%   check dimensions
[ix_up iy_up iz_up] = size(image);
%   calculate mean (zero if flag is set to zero)
error(nargchk(2,4,nargin));
if (nargin < 3)
    sigma = border;
end;
if (nargin > 3)
    if strmatch(flag,'zero')
        imdev = 0;
    end;
else
    imdev = 1;
end;
%   calculate mean values at edges
if imdev > 0
    if iz_up == 1 & iy_up == 1
    imdev = sum([image(1),image(ix_up)])/2;
    elseif iz_up == 1 & iy_up > 1
        imdev = (sum(image(1,:)) + sum(image(ix_up,:))+ ...
                sum(image(2:ix_up-1,1)) + sum(image(2:ix_up-1,iy_up))) ...
                / (2*(ix_up+iy_up)-2);
    else
        imdev = (sum(image(1,:,:)) + sum(image(ix_up,:,:))+ ...
        sum(image(2:ix_up-1,1,:)) + sum(image(2:ix_up-1,iy_up,:)) + ...
            sum(image(2:ix_up-1,2:iy_up-1,1)) + sum(image(2:ix_up-1,2:iy_up-1,iz_up))) ...
            / (2*iy_up*iz_up + 2*(ix_up-2)*iz_up + 2*(ix_up-2)*(iy_up-2));
    end;
end;


%   design filter
%   gaussian
xx = 1:border;
fact = (exp(-2*(xx.^2)./(sigma^2))-exp(-2))./(1-exp(-2));
%   if sigma < border : set values to zero for xx > sigma
if sigma < border
    fact(floor(sigma):border)=0;
end;
%   cosine^2 
%   xx = 1:border;
%   fact(:) = 0.5*((cos((border-xx)/border*pi))+1);

for ix = 1:border,
    if iz_up == 1 & iy_up == 1
        image(ix) = imdev + (image(ix)-imdev)*fact(border-ix+1);
        image(ix_up) = imdev + (image(ix_up)-imdev)*fact(border-ix+1);
    elseif iz_up == 1 & iy_up > 1
        image(ix,ix:iy_up)= imdev + (image(ix,ix:iy_up)-imdev)*fact(border-ix+1);
        image(ix_up,ix:iy_up)= imdev + (image(ix_up,ix:iy_up)-imdev)*fact(border-ix+1);
        image(ix+1:ix_up-1,ix)= imdev + (image(ix+1:ix_up-1,ix)-imdev)*fact(border-ix+1);
        image(ix+1:ix_up-1,iy_up)= imdev + (image(ix+1:ix_up-1,iy_up)-imdev)*fact(border-ix+1);
        iy_up = iy_up-1;
    else
        image(ix,ix:iy_up,ix:iz_up)= imdev + (image(ix,ix:iy_up,ix:iz_up)-imdev)*fact(border-ix+1);
        image(ix_up,ix:iy_up,ix:iz_up)= imdev + (image(ix_up,ix:iy_up,ix:iz_up)-imdev)* ...
            fact(border-ix+1);
        image(ix+1:ix_up-1,ix,ix:iz_up)= imdev + (image(ix+1:ix_up-1,ix,ix:iz_up)-imdev)*fact(border-ix+1);
        image(ix+1:ix_up-1,iy_up,ix:iz_up)= imdev + (image(ix+1:ix_up-1,iy_up,ix:iz_up)-imdev)...
            *fact(border-ix+1);
        image(ix+1:ix_up-1,ix+1:iy_up,ix)= imdev + (image(ix+1:ix_up-1,ix+1:iy_up,ix)...
            -imdev)*fact(border-ix+1);
        image(ix+1:ix_up-1,ix+1:iy_up,iz_up)= imdev + (image(ix+1:ix_up-1,ix+1:iy_up,iz_up)...
            -imdev)*fact(border-ix+1);
        iy_up = iy_up-1;
        iz_up = iz_up-1;
    end;
    ix_up = ix_up-1;
end;