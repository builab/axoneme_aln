function edge2 = edgeClip(edge, box)
%EDGECLIP clip an edge with a rectangular box
%
%   EDGE2 = edgeClip(EDGE, BOX);
%   EDGE : [x1 y1 x2 y2],
%   BOX : [xmin xmax ; ymin ymax] or [xmin xmax ymin ymax];
%   return :
%   EDGE2 = [xc1 yc1 xc2 yc2];
%
%   If clipping is null, return [0 0 0 0];
%
%   if edge is a [nx4] array, return an [nx4] array, corresponding to each
%   clipped edge.
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 14/05/2005.
%

%   HISTORY
%   08/01/2007 sort points according to position on edge, not to x coord
%       -> this allows to return edges with same orientation a source, and
%       to keep first or end points at the same position if their are not
%       clipped.
%   2007/08/27: rename as edgeClip

% process data input
if size(box, 1)==2
    box = box([1 3 2 4]);
end

% get limits of box
xmin = box(1);  xmax = box(2);
ymin = box(3);  ymax = box(4);

% convert box limits into lines
lineX0 = [xmin ymin xmax-xmin 0];
lineX1 = [xmin ymax xmax-xmin 0];
lineY0 = [xmin ymin 0 ymax-ymin];
lineY1 = [xmax ymin 0 ymax-ymin];


% compute outcodes of each vertex
p11 = edge(:,1)<xmin; p21 = edge(:,3)<xmin;
p12 = edge(:,1)>xmax; p22 = edge(:,3)>xmax;
p13 = edge(:,2)<ymin; p23 = edge(:,4)<ymin;
p14 = edge(:,2)>ymax; p24 = edge(:,4)>ymax;
out1 = [p11 p12 p13 p14];
out2 = [p21 p22 p23 p24];

% detect edges totally inside box -> no clip.
inside = sum(out1 | out2, 2)==0;

% detect edges totally outside box
outside = sum(out1 & out2, 2)>0;

% select edges not totally outside, and process separately edges totally
% inside box
ind = find(~(inside | outside));

% allocate memory
edge2 = zeros(size(edge));
edge2(inside, :) = edge(inside, :);

% iterate on edges
for i=1:length(ind)
    % current edge
    iedge = edge(ind(i), :);
        
    % compute intersection points with each line of bounding box
    px0 = intersectLineEdge(lineX0, iedge);
    px1 = intersectLineEdge(lineX1, iedge);
    py0 = intersectLineEdge(lineY0, iedge);
    py1 = intersectLineEdge(lineY1, iedge);
    
    % create array of points
    points  = [px0; px1; py0; py1; iedge(1:2); iedge(3:4)];
    
    % and remove infinite points (edges parallel to box edges)
	points  = points(isfinite(points(:,1)), :);
    
    % compute position of remaining points
    pos     = linePosition(points, createLine(iedge(1:2), iedge(3:4)));
    
    % sort points according to their position on the line
    [pos I] = sort(pos);
    points  = points(I, :);

    % select points on the boundary of box
    eps=1e-12;
    ins = find( points(:,1)-xmin>=-eps & points(:,2)-ymin>=-eps & ...
                points(:,1)-xmax<=eps & points(:,2)-ymax<=eps);
            
    if length(ins)>1
        edge2(ind(i), :) = [points(ins(1),:) points(ins(end),:)];
    end        
end


