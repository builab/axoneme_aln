function calc_weighted_avg(input, weightFile, output)
% CALC_WEIGHTED_AVG for avg tomographic volume
%	 calc_weighted_avg(input, weight, output)
% Parameters
%	input input file
%	output output file
%	weight weight file calculated from by calc_weight_factor
% HB 20071202

volstr  = tom_spiderread2(input);
wstr = tom_spiderread2(weightFile);
weight = wstr.data;

if min(min(min(weight))) == 0
	weight = weight + 1;
end

vol_cr = ifftn(fftn(volstr.data)./ifftshift(weight), 'symmetric');
tom_spiderwrite2(output, vol_cr);

