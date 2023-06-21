%----------------------------------------------------------
% Script threedmask_script.m
% @purpose To mask an input volume with a mask
% @version 1.0
% @date 20080429
%----------------------------------------------------------

% ---- TO CHANGE ------------------------------------------
input_file = 'trypa_avg_cr_mr.spi';
mask_file = 'trypa_3dmask.spi';
output_file = 'trypa_avg_cr_mr_m.spi';
% ----- DON'T CHANGE AFTER THIS LINE ----------------------


input = tom_spiderread2(input_file);
mask = tom_spiderread2(mask_file);

output = threedmask(input.data, mask.data);

tom_spiderwrite2(output_file, output);
