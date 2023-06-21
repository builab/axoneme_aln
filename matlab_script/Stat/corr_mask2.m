function corr = corr_mask2(vol1, vol2, mask)
% CORR_MASK2 calculate cross correlation with a faded mask.
%		corr = corr_mask2(vol1, vol2, mask)
% Also see corr_mask, xcorr2, prcorr2
% @author HB
% @date 15/08/2007
% TODO convert to C function for fast calculation

% Check mask
if max(max(max(mask))) > 1 && min(min(min(mask))) < 0
	error('Mask value must be between 0 & 1')
end

% Calculate vol
[m, n, p] = size(vol1);

vol1rs = reshape(vol1, 1, m*n*p);
vol2rs = reshape(vol2, 1, m*n*p);
maskrs = reshape(mask, 1, m*n*p);

datasize = sum(maskrs);
vol1_avg = sum(vol1rs.*maskrs)/datasize;
vol2_avg = sum(vol2rs.*maskrs)/datasize;

vol1_std = sqrt(sum(((vol1rs-vol1_avg).^2).*maskrs)/(datasize-1));
vol2_std = sqrt(sum(((vol2rs-vol2_avg).^2).*maskrs)/(datasize-1));

corr = sum((vol1rs - vol1_avg).*(vol2rs - vol2_avg).*maskrs)/(vol1_std*vol2_std*(datasize-1));
