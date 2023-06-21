function p = tom_spheremask(vol, radius, bgrd_value)
%TOM_SPHEREMASK mask a sphere to a volume
%
%Date: 17/01/07

if nargin < 2
	radius = ceil(min(size(vol))/2);
end

if nargin < 3
	bgrd_value = 0;
end

if radius > ceil(min(size(vol))/2)
	radius = ceil(min(size(vol))/2);
end

sphere = tom_sphere(size(vol), radius);
p = vol;
p(~sphere) = bgrd_value;
