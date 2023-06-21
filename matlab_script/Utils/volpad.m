function padded_vol = volpad(vol, padded_size, corner, bgoption)
% VOLPAD pads volume
%   padded_vol = volpad(vol, padded_size);
%   padded_vol = volpad(vol, padded_size, corner);
%   padded_vol = volpad(vol, padded_size, corner, bgoption);
% PARAMETERS
%   vol original volume
%   padded_size size of new volume
%   coor coordinate of corner
%   bgoption value of background
%       'avg'   average value of vol (default)
%        0      background value = 0
%
% See also volpad2n
%
% @author HB
% @date 2007/10/08, Untested

if nargin < 2
    disp('Too few arguments');
    help volpad
    exit;
end

[dimy dimx dimz] = size(vol);

if nargin < 3
    corner(1) = floor((padded_size(1) - dimx)/2) + 1;
    corner(2) = floor((padded_size(2) - dimy)/2) + 1;
    corner(3) = floor((padded_size(3) - dimz)/2) + 1;
end

if nargin < 4
    bgvalue = mean(mean(mean(vol)));
elseif (strcmp(bgoption, 'avg') == 1)
    bgvalue = mean(mean(mean(vol)));
elseif (strcmp(class(bgoption), 'double'))
    bgvalue = bgoption;
else
    disp('Unknown bgoption');
    help volpad
    exit;
end

padded_vol = bgvalue*ones(padded_size(2), padded_size(1), padded_size(3));
padded_vol(corner(2):corner(2)+dimy-1, corner(1):corner(1)+dimx-1,corner(3):corner(3)+dimz-1) = vol;


    