% ------------------------------------------------------------------
% Script: cp_model
% Purpose: drawing cp_model for visualization
% HB 20080717
% ------------------------------------------------------------------

% Output to txt file
clear
outputFile = '/mol/ish/Data/Huy_tmp/axoneme/rs_ascii.mod';

% Radial spoke position
rsOrient = [14 37 84 107 154 177; 
			45 67 115 137 185 207;
			11 34 81 104 151 174;
			35 58 105 128 175 198;
			19 65 89 135 159 205;
			42 67 112 137 182 207;
			0 50 0 0 0 0;
			3 25 73 95 143 165;
			46 69 116 139 186 209];

% Draw central pair
drawCylinder([0 0 0 0 0 225 20],'close')

directives.pointsize = 8;
directives.type = 'scattered';

radius = 40;
theta = 90*pi/180;
phi = 0;
increment = 2*pi/size(rsOrient, 1);

for doubletId = 1:size(rsOrient, 1)	
	disp(['DoubletID: ' num2str(doubletId)]);
	contour = [];
	for rsId = 1:size(rsOrient, 2)		
		line = createLine3d([0 0 rsOrient(doubletId, rsId)], theta, phi);
		% Create sphere
		p1 = [radius 0 rsOrient(doubletId, rsId)];
		p2 = [-radius 0 rsOrient(doubletId, rsId)];
		p3 = [0 radius rsOrient(doubletId, rsId)];
		p4 = [0 0 rsOrient(doubletId, rsId)+radius];
		sphere = createSphere(p1, p2, p3, p4);
		gc = intersectLineSphere(line, sphere); % Intersect

		% Getting the correct point on line
		if (phi >= 2*pi)
			phi = phi - 2*pi;
		end
 		
		if (phi <= pi/2)
			if (gc(1,1) >= 0 && gc(1,2) >= 0)
				ptsEnd = gc(1.,:);
			else
				ptsEnd = gc(2.,:);	
			end
		elseif (phi <= pi)
			if (gc(1,1) <= 0 && gc(1,2) >= 0)
				ptsEnd = gc(1.,:);
			else
				ptsEnd = gc(2.,:);	
			end
		elseif (phi <= pi*3/2)
			if (gc(1,1) <= 0 && gc(1,2) <= 0)
				ptsEnd = gc(1.,:);
			else
				ptsEnd = gc(2.,:);	
			end
		elseif (phi < pi*2)	
			if (gc(1,1) >= 0 && gc(1,2) <= 0)
				ptsEnd = gc(1.,:);
			else
				ptsEnd = gc(2.,:);	
			end
		end
		contour = [contour ; ptsEnd];
		xi = linspace(ptsEnd(1)/2,ptsEnd(1), 50);
		yi = linspace(ptsEnd(2)/2,ptsEnd(2), 50);
		zi = linspace(rsOrient(doubletId, rsId), rsOrient(doubletId, rsId), 50);
		plot3(xi, yi , zi);
		hold on
	end
	model.(['object' num2str(doubletId)]).contour1 = contour;
	directives.name = ['RS ' num2str(doubletId)];
	model.(['object' num2str(doubletId)]).directives = directives;
	phi = phi + increment;
end

axis([-radius radius -radius radius 0 100])
axis equal, box on

write_imod_ascii(model, outputFile);
