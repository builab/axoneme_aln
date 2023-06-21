%--------------------------------------------------
% Script
% @purpose: box out a part, increase density, then masked
% @date 20080502
%--------------------------------------------------

input_file = '/mol/ish/Data/20080312seaurchin/seaurchin_ida_v1_avg_sirt_masked_filt_inv.spi';
mask_file = '/mol/ish/Data/20080312seaurchin/seaurchin_ida_3dmask.spi';
output_file = '/mol/ish/Data/20080312seaurchin/seaurchin_ida_v1_avg_sirt_cr_masked_trim.spi';
scale = 0.8;

input = tom_spiderread2(input_file);
mask = tom_spiderread2(mask_file);

vol = input.data;
vol_trim = vol(61:85,122:146,62:80);
vol_trim = vol_trim*scale;
vol(61:85,122:146,62:80) = vol_trim;

output = threedmask(vol, mask.data);
tom_spiderwrite2(output_file, output);


%--------------------------------------------------
% Info
% dynein b/g
%vol_trim = vol(72:90,135:151,65:83);
% a/d b/g
% vol(72:90,132:151,48:83);
% ODA
% vol_trim = vol(34:75,76:115,:);
% vol_trim = vol_trim*scale;
% vol(34:75,76:115,:) = vol_trim;
