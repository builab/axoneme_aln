function weight = calc_weight_factor_par(vol_size, alnContent, taListContent, lower_limit)
% CALC_WEIGHT_FACTOR calculate weight factor from align file & ta_list
%        weight = calc_weight_factor_par(vol_size, alnContent, taListContent, lower_limit)
%	 
% Parameters
%	alnContent total content from alignment doc file
%	taListContent	content from taFile
%	vol_size size of weight factor
%	lower_limit limit of CCC for not including in final reconstruction
%  Outputs
%	weight wieght file in Fourier space.
%
% HB 20080414
	
if nargin < 4
	lower_limit = 0;
end
tilt_axis_angle = -90;

if size(alnContent, 2) < 4
	error([align_file ' has less than 4 columns']);
end

% Create original wedge info
weight = zeros(vol_size);

% Using lower limit
good_indx = alnContent(:, 4)  > lower_limit;
alnContent = alnContent(good_indx, 1:3);
taListContent = taListContent(good_indx, :);

parfor (i = 1:size(alnContent,1))
    wedge = missing_wedge_3dse_arbitrary(vol_size, tilt_axis_angle, taListContent(i,2), taListContent(i,3), alnContent(i,:));
    weight = weight + wedge;
end