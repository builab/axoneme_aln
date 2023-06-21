function output = threedmask(input, mask, bkgrd_flag, bkgrd_value)
% THREEDMASK masking an input by a specify mask
%	init = threedmask(input, mask, output, bkgrd_flag, bkgrnd_value)
% Parameters
%	IN
%		input 3d input file
%		mask 3d mask file with value between 0 & 1%		
%		bkgrd_flag 1 for use input's background average as background value, 0 for using different value
%		bkgrd_value Value to use if bkgrd_flag equal 0
%	OUTPUT
%		output	masked input
% HB 20080429
% 20100129 modify to fit with MM C from Spider

if nargin == 2
	bkgrd_flag = 1;
end

if nargin == 3
	bkgrd_value = 0;
end

if (bkgrd_flag)
	[m n p] = size(input);
	sphere_mask = 1 - tom_sphere([m n p], floor(min(min(m, n), p)/2) - 10); % get background value
	bkgrd_value = sum(sum(sum(sphere_mask.*input)))/sum(sum(sum(sphere_mask)));
end

output = (input - bkgrd_value).*mask + bkgrd_value;

   
