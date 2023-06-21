function fourier_view_helper(filename,option)
% FOURIER_VIEW_HELPER outputs amplitude and phase or real & imaginary parts
% filename = spider file
% option: 0 - amplitude & phase
%			 1 - real & imaginary
% Date: 16/01/07
% Too big contrast with first slide

if nargin < 2
	option = 0;
end

name = filename(1:length(filename)-4);

in = tom_spiderread2(filename);

if (~strcmp(in.transform, 'herm') && ~strcmp(in.transform, 'cent'))
	error('Not a fourier transform file !!!')
end

if in.mixrad == 1
	nsam = in.x*2 - 1;
else
	nsam = in.x*2 - 2;
end

data = zeros(in.y, nsam, in.z);

data(:, 1:floor(nsam/2)+1, :) = in.data;

remainx = nsam - floor(nsam/2)-2;

for i = 1:in.z
	data(:,nsam-remainx: nsam,i) = fliplr(conj(in.data(:,in.x-remainx:in.x,i)));
end

if option == 0
	name_am = strcat(name, '_am.spi');
	name_ph = strcat(name, '_ph.spi');
	am = sqrt(real(data).*real(data) + imag(data).* imag(data));
	tom_spiderwrite2(name_am, am);
	ph = atan2(imag(data), real(data));
	tom_spiderwrite2(name_ph, ph);
else
	name_real = strcat(name, '_r.spi');
	name_imag = strcat(name, '_i.spi');
	tom_spiderwrite2(name_real, real(data))
	tom_spiderwrite2(name_imag, imag(data))
end
