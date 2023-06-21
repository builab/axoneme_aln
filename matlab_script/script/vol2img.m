% Script to convert a volume to a 2D image by projection in Z direction
% 2009/10/13

inputFile = 'resp_ATPVi_avg_iter05_ref4_c001_cr.spi';
outputFile = 'resp_ATPVi_avg_iter05_ref4_c001_cr.png';

%------------------------------------------
vol = tom_spiderread2(inputFile);
img = sum(vol.data, 3);
img = vol2double(img);

imwrite(img, outputFile);
