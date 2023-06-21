% Script to calculate the 9fold symmetry of flagella and write  chimera
% marker model
% @comment Not so nice model created
shift = 1;
scale = 100;
len = 1500;
markerFile = 'flagellum.cmm';
color = [.7 .7 .7];
radius = 20;

tip = 0:40:320;
origin = [cos(tip*pi/180); sin(tip*pi/180)]';
origin_corr = (origin + shift)*scale;
origin_base = [origin_corr zeros(size(origin, 1), 1)];
origin_tip = [origin_corr zeros(size(origin, 1), 1) + len];
origin_3d = [origin_base; origin_tip];
links = [1:9; 10:18]';
write_chimera_marker(markerFile, origin_3d, links, color, radius);

% The membrane part by density map
mapFile = 'membrane.spi';
memLen = 300;
memInRadius = 125;
memThickness = 10;

dimXY = (memInRadius + memThickness) *2 + 10;
map = tom_cylinder(memInRadius, memInRadius + memThickness, [dimXY dimXY memLen]);
tom_spiderwrite2(mapFile, map);
