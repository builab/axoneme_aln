function out = herm_to_std(in, odd)
%HERM_TO_STD converts a compacted hermitian FT 2D or 3D matrix to a standard FT matrix
%	OUT = HERM_TO_STD(IN, ODD)
%
% @author HB
% @date 02082007

% default odd
if nargin < 2
	odd = 0;
end

nsam = size(in, 2);
nrow = size(in, 1);
nslice = size(in, 3);

% getting original dimension
if odd == 0
	xori = nsam*2 - 2;
else
	xori = nsam*2 - 1;
end

out = zeros(size(in,1), xori, size(in,3));
out(:,1:nsam,:) = in;

if odd == 0
    half = nsam - 1;
else
    half = nsam;
end

out(1,nsam+1:xori, 1) = fliplr(conj(in(1, 2:half, 1)));
out(2:nrow, nsam+1:xori, 1) = fliplr(flipud(conj(in(2:nrow, 2:half, 1))));

if (nslice > 1) % 3d case
    out(1,nsam+1:xori, 2:nslice) = fliplr(flipud(conj(squeeze(in(1, 2:half, 2:nslice)))));
    for i = 2: nslice
        %out(1,nsam+1:xori, i) = fliplr(conj(in(1, 2:half, nslice - i + 2)));
        out(2:nrow, nsam+1:xori, i) = fliplr(flipud(conj(in(2:nrow,2:half, nslice - i + 2))));
    end
end


