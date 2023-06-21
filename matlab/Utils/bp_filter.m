function bnd = bp_filter(dims, low, hi, sigma)
% BP_FILTER implements gaussian bandpass filter in 2D
%   bnd = bp_filter(filter_size, low, hi, sigma)
%
% PARAMETERS
%   dims size of filter
%   low low frequency
%   hi high frequency
%   sigma sigma
% Example
%   bnd = bp_filter([200 200 200], .05, .2, 3); 
%
% Code borrowed from tom_bandpass
% @author HB
% @date 2007/10/10
% TODO implement butterworth & fermi filter

if low >= hi
	error('Low frequency must be smaller than high frequency');
end

if hi > .5
	hi = .5;
end

if low < 0
	low = 0;
end

if low == 0
	lp = ones(dims);
else
	if nargin < 4
		lp = lp_filter(dims, hi);
	else
		lp = lp_filter(dims, hi, sigma);
	end
end

if hi == 0.5
	hp = ones(dims);	
else
	if nargin < 4
		hp = hp_filter(dims, low);
	else
		hp = hp_filter(dims, low, sigma);
	end
end

bnd = lp.*hp;

end

function lp = lp_filter(dims, hi, sigma)
% low pass filter
min_dim = min(dims);

if size(dims,2) == 2
    dims(3) = 1;
end

center=[floor(dims(1)/2)+1, floor(dims(2)/2)+1, floor(dims(3)/2)+1];

[x,y,z]=ndgrid(0:dims(1)-1,0:dims(2)-1,0:dims(3)-1);

radius = sqrt((x+1-center(1)).^2+(y+1-center(2)).^2+(z+1-center(3)).^2);

ind = find(radius > hi*min_dim);

lp = ones(dims(1), dims(2), dims(3));

lp(ind) = 0;

if (nargin > 2) 
    if (sigma > 0)
        lp(ind) = exp(-((radius(ind) - hi*min_dim)/sigma).^2);
        ind = find(lp < exp(-2));
    end;
    lp(ind) = 0;
end
end

function hp = hp_filter(dims, low, sigma)
% high pass filter
min_dim = min(dims);

if size(dims,2) == 2
    dims(3) = 1;
end

center=[floor(dims(1)/2)+1, floor(dims(2)/2)+1, floor(dims(3)/2)+1];

[x,y,z]=ndgrid(0:dims(1)-1,0:dims(2)-1,0:dims(3)-1);

radius = sqrt((x+1-center(1)).^2+(y+1-center(2)).^2+(z+1-center(3)).^2);

ind = find(radius < low*min_dim);

hp = ones(dims(1), dims(2), dims(3));

hp(ind) = 0;

if (nargin > 2) 
    if (sigma > 0)
        hp(ind) = exp(-((low*min_dim - radius(ind))/sigma).^2);
        ind = find(hp < exp(-2));
    end;
    hp(ind) = 0;
end
end
