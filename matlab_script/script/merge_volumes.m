%%-------------------------------------------------------
% Script: merge_volumes.m
% @purpose Merge different parts of 2 volumes into 1
% @date 20090305
%%-------------------------------------------------------

input01 = 'tetra_ida_v1_avg_cr_scale1_374.spi'; % dark part of the mask
input02 = 'mtb_pad_aln.spi'; % while part of the mask
normMaskFile = 'tetra_ida_v1_3dmask.spi';
maskFile = 'tetra_ida_v1_3dmask.spi';
output = 'tetra_ida_v1_avg_sync.spi';

%--------------------------------

vol01 = tom_spiderread2(input01);
vol02 = tom_spiderread2(input02);
normMask = tom_spiderread2(normMaskFile);
mask = tom_spiderread2(maskFile);


vol01 = vol01.data;
vol02 = vol02.data;
mask = mask.data;
normMask = normMask.data;

[m n p] = size(vol01);

% Normalize
vol01norm = norm_inside_mask(vol01, 1-normMask);
vol02norm = norm_inside_mask(vol02, normMask);

% matching background
bg01 = sum(sum(sum(vol01norm.*(1-normMask))))/sum(sum(sum(vol01norm.*(1-normMask))));
bg02 = sum(sum(sum(vol02norm.*normMask)))/sum(sum(sum(vol02norm.*normMask)));

vol = (1 - mask).*vol01norm +  mask.*vol02norm;

tom_spiderwrite2(output, vol);
