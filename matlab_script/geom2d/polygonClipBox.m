function poly2 = polygonClipBox(polygon, box)
%POLYGONCLIPBOX clip a polygon with a rectangular window
%
%   POLY2 = polygonClipBox(POLY, BOX)
%   POLY is [Nx2] array of points
%   BOX has the form: [xmin xmax ymin ymax].
%
%   Works only for convex polygons at the moment.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 14/05/2005.
%

%   HISTORY
%   30/05/2007 rename and update doc


% check case of polygons stored in cell array
if iscell(polygon)
    poly2 = cell(1, length(polygon));
    for i=1:length(polygon)
        poly2{i} = polygonClipBox(polygon{i}, box);
    end
    return;
end

% check case of empty polygon
N = size(polygon, 1);
if N==0
    poly2 = zeros(0, 2);
    return
end

% create edges array of polygon
edges = [polygon polygon([2:N 1], :)];

% clip edges
edges = clipEdge(edges, box);

% select non empty edges, and get theri vertices
ind = sum(abs(edges), 2)>1e-14;
pts = unique([edges(ind, 1:2); edges(ind, 3:4)], 'rows');

% add vertices of window corner
corners = [box(1) box(3); box(1) box(4);box(2) box(3);box(2) box(4)];
ind = inpolygon(corners(:,1), corners(:,2), polygon(:,1), polygon(:,2));
pts = [pts; corners(ind, :)];

% polygon totally outside the window
if size(pts, 1)==0
    poly2 = pts;
    return;
end

% compute centroid of visible polygon
pc = centroid(pts);

% sort vertices around polygon
angle = edgeAngle([repmat(pc, [size(pts, 1) 1]) pts]);
[dummy I] = sort(angle);

% create resulting polygon
poly2 = pts(I, :);
