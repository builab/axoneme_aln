%%-------------------------------------------------------
% Script: merge_volumes.m
% @purpose Merge different parts of 2 volumes into 1
% @date 20090305
%%-------------------------------------------------------

input01 = 'wt_dc_avg_cr_rs.spi'; % dark part of the mask
input02 = 'rs_pad_rs.spi'; % while part of the mask
maskFile = 'rs_merge_3dmask.spi';
output = 'wt_dc_rs_merged_02.spi';
scaleFactor = 0.930106;
addFactor = 0.0098549;

%--------------------------------

vol01 = tom_spiderread2(input01);
vol02 = tom_spiderread2(input02);
mask = tom_spiderread2(maskFile);


vol01 = vol01.data;
vol02 = vol02.data;
mask = mask.data;

[m n p] = size(vol01);

% Normalize
vol02 = vol02*scaleFactor + addFactor;

vol = (1 - mask).*vol01 +  mask.*vol02;

tom_spiderwrite2(output, vol);
