function [x, y, z] = calcStagePosition(currX, currY, currZ, dx, dy, dz, mag, ccdPixelSize)
% calcStagePosition return the state position
%			[x, y, z] = calcStagePosition(currX, currY, currZ, dx, dy, dz, mag, ccdPixelSize)
% Parameter
%	IN
%	currX
%	currY
%	currZ
%	dx
%	dy
%	dz
%	mag
%	OUT
%	x, y, z

ccdPixelSize = 14
magFactor = ccdPixelSize/mag;

x = currX + dx*magFactor;
y = currY + dy*magFactor;
z = currZ + dz*magFactor;
