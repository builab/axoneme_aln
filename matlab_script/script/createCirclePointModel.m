%-------------------------------------------------
% SCRIPT: createCircleVol.m
% @purpose create a point model (IMOD) containing circles with arbitrary orientation 
% @date 20080506
% @note need geom3d
%-------------------------------------------------
%PARAMETERS
%  IN
%	origins				N x 3 maxtrix contains N rings' origins.
%	theta				N x 1 matrix contains theta angle of corresponding rings	 
%	phi					N x 1 matrix contains phi angle of corresponding rings
%  OUT
%   outputPointFile		output IMOD point model
%
% ADDITIONAL INFO
%  OAD A origin = [85 46 100]; theta = 85; phi = 287;
%  OAD B origin = [89 58 105]; theta = 90; phi = 97;
%  OAD G origin = [99 68 110]; theta = 80; phi = 99;
%  IAD 1 origin = [123 81 29]; theta = 90; phi = 0; 
%  IAD 2 origin = [136 82 39]; theta = -55; phi = 6;
%  IAD 3 origin = [140 82 56]; theta = 75; phi = 195;
%  IAD 4 origin = [142 80 76]; theta = 85; phi = 200;
%  IAD 5 origin = [136 82 95]; theta = 85; phi = 174; 
%  IAD 6 origin = [143 81 111]; theta = 75; phi = 190; 
%  IAD 7 origin = [138 81 137]; theta = -55; phi = 347; 
%  IAD 8 origin = [144 82 152]; theta = -85; phi = 200; 


%%% --- START HEADER ---
outputPointFile = 'point.txt';

origins = [15 15 15]; % Default for apo WT [A B G]
theta = 80;
phi = 36;
psi = 0;
%%% --- END HEADER -----

% ----- program default -----------
vol_size = [32 32 32];
radius = 6;
% ---------------------------------

number_of_rings = size(origins, 1);

fid = fopen(outputPointFile, 'wt');

for ringId = 1:number_of_rings
	circle = createCircle3d(origins(ringId,:), radius, theta(ringId)*pi/180, phi(ringId)*pi/180, psi(ringId)*pi/180);
	for pointId = 1:size(circle, 1)
		fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(pointId, 1), circle(pointId, 2), circle(pointId, 3));
    end
    fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(1, 1), circle(1, 2), circle(1, 3));
    fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(2, 1), circle(2, 2), circle(2, 3));
    fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(3, 1), circle(3, 2), circle(3, 3));
    fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(4, 1), circle(4, 2), circle(4, 3));
    fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', 1, ringId, circle(5, 1), circle(5, 2), circle(5, 3));
end

fclose(fid);

