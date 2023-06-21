%----------------------------------------------------------------
% Script diffmap3d.m
% Purpose: fitting two map using least square fitting & get different map
% Date: 2008/11/10
%----------------------------------------------------------------

% Diff map
vol1_file = 'wt_prox_d234789_avg_cr_filt_inv.spi';
vol2_file = 'pf14_0x_dc_avg_cr_filt_inv.spi';
maskFile = 'oda1_3dmask.spi';

output = 'diffmap_wt_pf14.spi';


% Read
vol1 = tom_spiderread2(vol1_file);
vol2 = tom_spiderread2(vol2_file);
mask = tom_spiderread2(maskFile);


vol1 = vol1.data;
vol2 = vol2.data;
mask = mask.data;
mask = mask > .5;

[m n p] = size(vol1);

vol1rs = reshape(vol1, 1, m*n*p);
vol2rs = reshape(vol2, 1, m*n*p);
mask = reshape(mask, 1, m*n*p);

vol1m = vol1rs(mask==1);
vol2m = vol2rs(mask==1);

% Least Square Fitting
pc = polyfit(vol1m, vol2m, 1);
vol1rs_scale = polyval(pc,vol1rs);
diffmap = vol1rs_scale - vol2rs;
diffmap = reshape(diffmap, m, n, p);
tom_dspcub(diffmap,[])

tom_spiderwrite2(output, diffmap);


% Trying to vary threshold (Does not make a different)
%threshold_list = linspace(pc(1) - .2, pc(1) + .2, 5);
%for i = 1:length(threshold_list)
%    vol1_scale = polyval([threshold_list(i) pc(2)], vol1);
%    diffmap = vol1rs_scale - vol2r;
%    diffmap = reshape(diffmap.*mask, m, n, p);
%    tom_spiderwrite2([output2 sprintf('%0.2d', i) '.spi'], diffmap);
%end
