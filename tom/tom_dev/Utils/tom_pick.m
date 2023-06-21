function p = tom_pick(oriVol, origin, radius, do_mask, bgrd_value)
%TOM_PICK picking a volume from a volume
%Date: 17/01/07

if nargin < 3
	error('Insufficient arguments !!!')
end

if nargin < 4
	do_mask = 0;
end

if nargin < 5
	bgrd_value = 0;
end

% extract
istart = origin - radius;
iend = origin + radius - 1;

% checking
for i = 1:3
	if istart(i) < 1 || iend(i) > size(oriVol, i)
		error('Radius too big!!!')
	end
end

p = oriVol(istart(1): iend(1), istart(2): iend(2), istart(3): iend(3));

if do_mask
	p = tom_spheremask(p, radius, bgrd_value);
end
