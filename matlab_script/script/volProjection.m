% Script to convert a volume to a 2D image by projection in Z direction
% 2009/10/13

inputFile = 'trypanosoma_rs_avg4_cr_filt_inv.spi';
outputFile = 'trypanosoma_rs_RSP3_2d.png';

%------------------------------------------
vol = tom_spiderread2(inputFile);
img = sum(vol.data, 1);
img = squeeze(img);
img = vol2double(img);

imwrite(img, outputFile);
