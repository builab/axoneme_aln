function scaledFt = ps_scaleup(particleFt, avgFt, wedge, hiFreq)
% PS_SCALEUP power spectrum scale up
%	scaledFt = ps_scaleup(particleFt, avgFt, wedge, hiFeq)
% Parameters
%	Input
%		particleFt Fourier transform of particle
%		avgFt	Fourier transform of average
%		wedge	missing wedge
%		hiFreq high frequency from that excluded
%	Ouput
%		scaledFt Scaled FT of average to match with particle FT
% HB 20080609

[m, n, p] = size(particleFt);
mask = tom_sphere([m n p], hiFreq*min(min(m,n),p), 3);

particlePs = sum(sum(sum(abs(particleFt.*wedge.*mask))));
avgPs = sum(sum(sum(abs(avgFt.*wedge.*mask))));

scaledFt = (particlePs/avgPs)*avgFt;

