%----------------------------------------------------------
% Script G_threedmask_script.m
% @purpose To join 2 masks with different orientations
% @version 1.0
% @date 20080429
%----------------------------------------------------------

% ---- TO CHANGE ------------------------------------------
mask1_file = 'trypanosoma_rs_tight1_3dmask.spi';
mask2_file = 'trypanosome_rs_RSP3_3dmask.spi';
output_file = 'trypanosoma_rs_RSP3_tight1_3dmask.spi';
% ----- DON'T CHANGE AFTER THIS LINE ----------------------


mask1 = tom_spiderread2(mask1_file);
mask2 = tom_spiderread2(mask2_file);


output = mask1.data .* mask2.data;

tom_spiderwrite2(output_file, output);
