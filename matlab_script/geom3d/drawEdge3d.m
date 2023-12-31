function varargout = drawEdge3d(edge, varargin)
%DRAWEDGE3D draw the edge in the current Window
%   drawEdge(edge) draw the edge on the current axis. If edge is not
%   clipped by the axis, function return -1.
%
%   Note: deprecated, use geom2d/drawEdge instead (more generic)
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 18/02/2005.
%

%   HISTORY
%   04/01/2007: remove unused variables


lim = get(gca, 'xlim');
xmin = lim(1);
xmax = lim(2);
lim = get(gca, 'ylim');
ymin = lim(1);
ymax = lim(2);
lim = get(gca, 'zlim');
zmin = lim(1);
zmax = lim(2);


% box faces parallel to Oxy
planeZ0 = [xmin ymin zmin 1 0 0 0 1 0];
planeZ1 = [xmin ymin zmax 1 0 0 0 1 0];

% box faces parallel to Oxz
planeY0 = [xmin ymin zmin 1 0 0 0 0 1];
planeY1 = [xmin ymax zmin 1 0 0 0 0 1];

% box faces parallel to Oyz
planeX0 = [xmin ymin zmin 0 1 0 0 0 1];
planeX1 = [xmax ymin zmin 0 1 0 0 0 1];

% compute itnersection point with each plane
lin = [edge(:,1:3) edge(:,4:6)-edge(:,1:3)];
piZ0 = intersectPlaneLine(planeZ0, lin);
piZ1 = intersectPlaneLine(planeZ1, lin);
piY0 = intersectPlaneLine(planeY0, lin);
piY1 = intersectPlaneLine(planeY1, lin);
piX1 = intersectPlaneLine(planeX1, lin);
piX0 = intersectPlaneLine(planeX0, lin);
points = [piX0;piX1;piY0;piY1;piZ0;piZ1];

% sort point according to position on edgee
pos = linePosition3d(points, lin);
ind = find(~isnan(pos));

points = sortrows(points);

pts = [edge(:,1:3); edge(:,4:6)];

h = line(pts(:,1)', pts(:,2)', pts(:,3)');
if length(varargin)>0
    set(h, varargin{:});
end

if nargout>0
    varargout{1}=h;
end