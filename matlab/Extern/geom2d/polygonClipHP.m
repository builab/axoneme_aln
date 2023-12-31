function poly2 = polygonClipHP(poly, line)
%POLYGONCLIPHP clip a polygon with Half-plane defined with directed line
%
%   usage :
%   POLY2 = polygonClipHP(POLY, LINE)
%   POLY is a [Nx2] array of points, and LINE is given as [x0 y0 dx dy].
%   The result POLY2 is also an array of points, sometimes smaller than
%   poly, and that can be [0x2] (empty polygon).
%
%   TODO: not yet implemented
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/07/2005.
%

%   HISTORY
%   15/08/2005: add test to avoid empty polygons 
%   13/06/2007: rewrite from clipPolygonHP

% avoid to process empty polygons
if size(poly, 1)<3
    poly2 = zeros([0 2]);
    return;
end

% ensure the last point is the same as the first one
if sum(poly(end, :)==poly(1,:))~=2
    poly = [poly; poly(1,:)];
end

N = size(poly, 1);
edges = [poly([N 1:N-1], :) poly];

b = isLeftOriented(poly, line);

% case of totally clipped polygon
if sum(b)==0
    poly2 = zeros(0, 2);
    return;
end
 

poly2 = zeros(0, 2);

i=1;
while i<=N
    
    if isLeftOriented(poly(i,:), line)
        % keep all points located on the right side of line
        poly2 = [poly2; poly(i,:)];
    else
        % compute of preceeding edge with line
        if i>1
            poly2 = [poly2; intersectLineEdge(line, edges(i, :))];
        end    
        
        % go to the next point on the left side
        i=i+1;
        while i<=N
            
            % find the next point on the right side
            if isLeftOriented(poly(i,:), line)
                % add intersection of previous edge
                poly2 = [poly2; intersectLineEdge(line, edges(i, :))];
                
                % add current point
                poly2 = [poly2; poly(i,:)];
                
                % exit the second loop
                break;
            end
            
            i=i+1;
        end
    end
    
    i=i+1;
end

% remove last point if it is the same as the first one
if sum(poly2(end, :)==poly(1,:))==2
    poly2 = poly2(1:end-1, :);
end

