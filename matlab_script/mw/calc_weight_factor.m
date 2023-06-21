function weight = calc_weight_factor(volSize, alnContent, taListContent, lowerLimit)
% CALC_WEIGHT_FACTOR calculate weight factor from align file & ta_list
%        weight = calc_weight_factor(volSize, alnContent, taListContent, lowerLimit)
%	 
% Parameters
%	alnContent total content from alignment doc file
%	taListContent	content from taFile
%	volSize size of weight factor
%	lowerLimit limit of CCC for not including in final reconstruction
%
% HB 20080812
	
if nargin < 4
	lowerLimit = 0;
end

tiltAxisAngle = 90;

if size(alnContent, 2) < 4
	error([align_file ' has less than 4 columns']);
end

% Create original wedge info
weight = zeros(volSize);

% Using lower limit
good_indx = alnContent(:, 4)  > lowerLimit;
alnContent = alnContent(good_indx, 1:3);
taListContent = taListContent(good_indx, :);

for i = 1:size(alnContent,1)
    wedge = missing_wedge_3d_arbitrary(volSize, tiltAxisAngle, taListContent(i,2), taListContent(i,3), alnContent(i,:));
    weight = weight + wedge;
	if rem(i,10) == 0
		disp(i)
	end
end
