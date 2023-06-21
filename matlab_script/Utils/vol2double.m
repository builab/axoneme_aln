function voldb = vol2double(vol)
% VOL2DOUBLE scale volume value to double between 0 & 1 (similar to im2double)
%   voldb = vol2double(vol)
%
% @author HB
% @date 20071010

voldb = double(vol) - min(min(min(vol)));
voldb = voldb/max(max(max(voldb)));