%%-------------------------------------------------------
% Script: merge_volumes.m
% @purpose Merge different parts of 2 volumes into 1
% @date 20090305
%%-------------------------------------------------------

input01 = 'tetra_trim2.spi'; % dark part of the mask
input02 = 'mtb_avg_pad.spi'; % while part of the mask
normMaskFile01 = 'doublet_3dmask.spi';
normMaskFile02 = 'singlet_3dmask.spi';
%maskFile = 'rs_merge_3dmask.spi';
output = 'CB_ida_v1_avg_syn.spi';

%--------------------------------

vol01 = tom_spiderread2(input01);
vol02 = tom_spiderread2(input02);
normMask02 = tom_spiderread2(normMaskFile02);
normMask01 = tom_spiderread2(normMaskFile01);
%mask = tom_spiderread2(maskFile);


vol01 = vol01.data;
vol02 = vol02.data;
%mask = mask.data;
normMask01 = normMask01.data;
normMask02 = normMask02.data;

[m n p] = size(vol01);

% Normalize
vol01norm = norm_inside_mask(vol01, normMask01);
vol02norm = norm_inside_mask(vol02, normMask02);

% matching background
bg01 = sum(sum(sum(vol01norm.*normMask01)))/sum(sum(sum(normMask01)))
bg02 = sum(sum(sum(vol02norm.*normMask02)))/sum(sum(sum(normMask02)))

vol = normMask01.*vol01norm +  normMask02.*vol02norm;

tom_spiderwrite2(output, vol);
