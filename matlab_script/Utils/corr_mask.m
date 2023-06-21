function r = corr_mask(x, y, mask)
% CORR_MASK FOR 1D, 2D or 3D only
%       r = corr_mask(x, y, mask)
% HB, 12/04

if nargin < 3
    mask = ones(size(x));
end

if strcmp(class(mask),'double') ~= 1
    mask = double(mask);
end

x_mask = x.*mask;
y_mask = y.*mask;

r = prcorr2(x_mask, y_mask);