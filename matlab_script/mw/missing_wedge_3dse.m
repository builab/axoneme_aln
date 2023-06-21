function wedge = missing_wedge_3dse(vol_size, tiltaxis, neg_tilt, pos_tilt, hsize, sigma)
% MISSING_WEDGE_3DSE create missing wedge with Gaussian soft edge (Experimental)
%   wedge = missing_wedge_3dse(size, tiltaxis, neg_tilt, pos_tilt, hsize, sigma)
%
%   MISSING_WEDGE produces a wedge shaped array. 
%   This array can be used as a window filter in Fourier space...
%
% PARAMETERS
% IN
%   vol_size   volume size
%   tiltaxis  tilt axis angle
%   neg_tilt negative tilt angle
%   pos_tilt positive tilt angle
%	hsize	size of Gaussian filter (default 3)
%	sigma	sigma of the Gaussian filter (default 1)
% OUT
%   wedge   output
%
%
% EXAMPLE
%   wedge=missing_wedge_3d([80 80 80],-95.5, -60, 60, 3, 1);
%   tom_dspcub(wedge,1);
%
% SEE ALSO
%   tom_wedge, missing_wedge_3d, missing_wedge_3d_arbitrary
%
% REFERENCE
%	tom_wedge & Bsoft
%
% @author HB
% @date 20080804


if nargin < 4
    error('Too few arguments');
end


if nargin < 5
	hsize = 3;
	sigma = 1;
end

warning off MATLAB:divideByZero;
       
neg_y_angle = (90 - abs(neg_tilt))*pi/180;
pos_y_angle = (90 - abs(pos_tilt))*pi/180;
pad = 15;
dimx = vol_size(1)+pad*2;
dimy = vol_size(2)+pad*2;
dimz = vol_size(3)+pad*2;

[x,y,z] = ndgrid(-floor(dimx/2):-floor(dimx/2)+dimx-1,-floor(dimy/2):-floor(dimy/2)+dimy-1,-floor(dimz/2):-floor(dimz/2)+dimz-1);

wedge = ones(dimx, dimy, dimz);

ind_pos = tan(pos_y_angle) > abs(x)./abs(z);
mask_pos = x.*z < 0;
ind_pos(mask_pos) = 0;
ind_neg = tan(neg_y_angle) > abs(x)./abs(z);
mask_neg = x.*z > 0;
ind_neg(mask_neg) = 0;
wedge(ind_pos)=0;
wedge(ind_neg)=0;

wedge  = tom_rotate(wedge, [tiltaxis 0 0]);
wedge = wedge > .5;
wedge = wedge(pad+1:pad+vol_size(1),pad+1:pad+vol_size(2), pad+1:pad+vol_size(3));

g = fspecial('gaussian', hsize, sigma);
wedge = imfilter(double(wedge), g);
