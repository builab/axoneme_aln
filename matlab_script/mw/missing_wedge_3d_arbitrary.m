function wedge = missing_wedge_3d_arbitrary(vol_size, tiltaxis, neg_tilt, pos_tilt, euler, hsize, sigma)
% MISSING_WEDGE_3D_ARBITRARY creates an Gaussian SOFT EDGE arbitrary wedge (EXPERIMENTAL FUNCTION)
%	wedge = missing_wedge_3d_arbitrary([dimx dimy dimz], tiltaxis, neg_tilt, pos_tilt, [phi theta psi], hsize, sigma)
%
% PARAMETERS
%   vol_size   volume size
%   tiltaxis  tilt axis angle
%   neg_tilt negative tilt angle
%   pos_tilt positive tilt angle
%   [phi theta psi] euler angle
%   hsize	size of Gaussian filter (default 3)
%   sigma	sigma of the Gaussian filter (default 1)
%   wedge   output
%
% Example
%   wedge = missing_wedge_3d_arbitrary([128 128 128], -95.5, -60, 60, [30 0 0], 3, 1);
%   tom_dspcub(wedge, 0)
%
% @author HB
% @date 26072007
% @last_modified 20082007 (using missing_wedge.m instead of tom_wedge.m)
% @last modified 20071206 adjust parameters to be compatible with Imod's
% align.log output
%  Temporary solution, same as missing_wedge_3dse_arbitrary




if nargin < 5
    error('Too few arguments')
end

if nargin < 6
	hsize = 3;
	sigma = 1;
end


if euler(1) == 0 && euler(2) == 0 && euler(3) == 0
    
    wedge = missing_wedge_3d(vol_size, tiltaxis, neg_tilt, pos_tilt, hsize, sigma);
    
else
    dim = floor(max(vol_size)*1.8);

    % Make odd dim
    if mod(dim,2) == 0
        dim = dim + 1;
    end

    wedge_big = missing_wedge_3d([dim dim dim], tiltaxis, neg_tilt, pos_tilt, hsize, sigma);
    wedge_big = tom_rotate(wedge_big, [euler(1) euler(3) euler(2)]);

    minx = floor(dim/2) - floor(vol_size(2)/2) + 1;
    miny = floor(dim/2) - floor(vol_size(1)/2) + 1;
    minz = floor(dim/2) - floor(vol_size(3)/2) + 1;

    wedge = wedge_big(miny:miny+vol_size(1)-1, minx : minx+vol_size(2)-1, minz : minz+vol_size(3)-1);
end
