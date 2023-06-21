%-------------------------------------------------
% Script: createCircleVol.m
% @purpose create a circle with arbitrary orientation inside a 3d volume
% @date 20090722
% @note need geom3d
%-------------------------------------------------
%PARAMETERS
%  IN
%	origins				N x 3 maxtrix contains N rings' origins.
%	theta				N x 1 matrix contains theta angle of corresponding rings	 
%	phi					N x 1 matrix contains phi angle of corresponding rings
%  OUT
%   outputFile			3d file contains the rings
%
% ADDITIONAL INFO
%  OAD A origin = [85 46 100]; theta = 85; phi = 287;
%  OAD B origin = [91 58 105]; theta = 90; phi = 97;
%  OAD G origin = [97 68 110]; theta = 80; phi = 99;
%  IAD 1 origin = [123 81 29]; theta = 90; phi = 0; 
%  IAD 2 origin = [136 82 39]; theta = -55; phi = 6;
%  IAD 3 origin = [140 82 56]; theta = 75; phi = 195;
%  IAD 4 origin = [142 80 76]; theta = 85; phi = 200;
%  IAD 5 origin = [136 82 95]; theta = 85; phi = 174; 
%  IAD 6 origin = [143 81 111]; theta = 75; phi = 190; 
%  IAD 7 origin = [138 81 137]; theta = -55; phi = 347; 
%  IAD 8 origin = [144 82 152]; theta = -85; phi = 200; 

%%% --- START HEADER ---
outputFile = 'ring_apo.spi';
origins = [ 85 46 100; 
			91 58 105; 
			97 68 110]; % Default for apo WT [A B G]
theta = [85 
		 90
         80];
phi = [287
        97
        99];
%%% --- END HEADER -----

% ----- program default -----------
vol_size = [200 200 200];
radius = 7;
sigma = 4; hi = 30; low = 4;
% ---------------------------------

number_of_rings = size(origins, 1);

vol = zeros(vol_size);

for ringId = 1:number_of_rings
	circle = createCircle3d(origins(ringId,:), radius, theta(ringId)*pi/180, pi/2, phi(ringId)*pi/180 - pi/2);
	circle = round(circle);

	for i = 1:size(circle, 1)
		vol(circle(i,2), circle(i,1), circle(i,3)) = 1;
	end
end

vol = tom_bandpass(vol, low, hi, sigma);

tom_spiderwrite2(outputFile, vol);
