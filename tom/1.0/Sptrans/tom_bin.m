function binned = tom_bin(im,nbin)
% TOM_BIN performs binning of 1D, 2D or 3D images
%
%   binned = tom_bin(im,nbin)
%   
%   E.g. 1D: pixels 1 and 2 are averaged and stored as pixel one of BINNED, pixels 3 and 4 
%   of IM are averaged and stored as pixel 2 of BINNED. The dimensions of
%   BINNED are half of IM. For multiple binning TOM_BIN nbin >1 can be used. 
%
% INPUT
%   IM          : image
%   NBIN        : number of binnings (default = 1)
%
% OUTPUT
%   BINNED      : binned image
%
%   03/14/03 FF
%   13.01.05. VL: added nbin = 0 case
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

error(nargchk(1,2,nargin))
if (nargin < 2)
    nbin = 1;
end;
%im=double(im); % modified by SN for 64 BIT
for ibin =1:nbin
    if (size(im,3) == 1 & size(im,2) > 1 & size(im,1) > 1)
        binned = (im(1:2:size(im,1)-1,1:2:size(im,2)-1)+im(1:2:size(im,1)-1,2:2:size(im,2))+im(2:2:size(im,1),1:2:size(im,2)-1)+im(2:2:size(im,1),2:2:size(im,2)))/4;
    elseif (size(im,3) > 1 & size(im,2) > 1 & size(im,1) > 1)
        binned = (im(1:2:size(im,1)-1,1:2:size(im,2)-1,1:2:size(im,3)-1)+im(1:2:size(im,1)-1,2:2:size(im,2),1:2:size(im,3)-1)+...
            im(2:2:size(im,1),1:2:size(im,2)-1,1:2:size(im,3)-1)+im(2:2:size(im,1),2:2:size(im,2),1:2:size(im,3)-1) +...
            im(1:2:size(im,1)-1,1:2:size(im,2)-1,2:2:size(im,3))+im(1:2:size(im,1)-1,2:2:size(im,2),2:2:size(im,3))+...
            im(2:2:size(im,1),1:2:size(im,2)-1,2:2:size(im,3))+im(2:2:size(im,1),2:2:size(im,2),2:2:size(im,3)))/8;
    else
        binned = (im(1:2:size(im,1)-1)+im(2:2:size(im,1)))/2;
    end;
    im = binned;
end;

% if no binning
if nbin == 0
    binned = im;
end;

