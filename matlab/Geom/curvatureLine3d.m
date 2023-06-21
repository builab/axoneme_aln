function c = curvatureLine3d(points, ptsDistance)
%CURVATURELINE3D finding the curvature of each point of the line
%  c = curvatureLine3d(points)
%  c = curvatureLine3d(points, ptsDistance)
%PARAMETERS
% IN
%  points 	Nx3 array
%  ptsDistance	How many points apart is use to calculate the curvature
% OUT
%  curvature of each points, the end point's curvature is approximate as its neighbor's curvature
% HB 2010/01/07 based on geom2d, quite problematic for short line.

if (nargin < 2)
	ptsDistance = 5;
end

if (size(points, 1) < 3)
	error('Less than 3 points');	
end

if (size(points, 1) < 12)
	ptsDistance = 2;
end

if (size(points, 1) < 6)
	ptsDistance = 1;
end

if size(points, 1) == 3
	r = radiusFrom3Pts(points(1,:), points(2,:), points(3,:));
	c = 1./r;
	c = [c ; c ; c];
else
	p1 = points(1:end-2*ptsDistance, :);
	p2 = points(ptsDistance + 1: end- ptsDistance, :);
	p3 = points(2*ptsDistance + 1: end,:);
	r = radiusFrom3Pts(p1, p2, p3);
	c = 1./r;
	c = [c(1)*ones(ptsDistance, 1); c; c(end)*ones(ptsDistance, 1)];
end
