function varargout = cross_section_from_flagella_model(model, doubletList, lowerBound, upperBound)
% CROSS_SECTION_FROM_FLAGELLA_MODEL calculate points in the cross section
% of a flagella model between the lower and upperBound
%	pointArray = cross_section_from_flagella_model(model, doubletList, lowerBound, upperBound)
%   [pointArray, pointList] = cross_section_from_flagella_model(model, doubletList, lowerBound, upperBound)
% PARAMETERS
%  IN
%   model          flagella model (output of function flagella_model_from_pts)
%   doubletList    list of doublet to calculate
%   lowerBound     lowerBound in the sorting dimension
%   upperBound     upperBound in the sorting dimension
%  OUT
%   pointArray     [n x 3] array of point, n = number of doublet
%   pointList      index in model.Line
% EXAMPLES
%  points = cross_section_from_flagella_model(model, 800, 1200);
% HB 20110107

DIST_THRESHOLD = 1;
ADJ_PTS = 2;

%Find the nearest point to the lowerBound in the fisrt doublet
sortDim = model(doubletList(1)).SortDim;
[minval, pointId] = min(abs(model(doubletList(1)).Line(:, sortDim) - lowerBound));
[maxval, maxPointId] = min(abs(model(doubletList(1)).Line(:, sortDim) - upperBound));

if pointId <= ADJ_PTS
    pointId = ADJ_PTS + 1;
end

if maxPointId >= size(model(doubletList(1)).Line, 1) - ADJ_PTS
    maxPointId = size(model(doubletList(1)).Line, 1) - ADJ_PTS;
end

%Iterate to find cutting plane

doCutAll = 0;
increment = 5;

pointList = zeros(size(doubletList));
pointArray = zeros(length(doubletList), 3);

while (~doCutAll && (pointId <= maxPointId))     
    point = model(doubletList(1)).Line(pointId, :);
    adjPoints = model(doubletList(1)).Line(pointId-ADJ_PTS:pointId+ADJ_PTS,:);
    line = fitline3d(adjPoints');
    pNormal = diff(line,1,2);
    d = - sum(pNormal'.*point);
    pointList(1) = pointId;
    pointArray(1, :) = point;
    doCutAll = 1;
    
    for i = 1:length(doubletList) 
        doubletId = doubletList(i);
        oxyzi = model(doubletId).Line;
        repPn = repmat(pNormal',size(oxyzi,1),1);
        distance = abs(sum(oxyzi.*repPn,2) + d)/sqrt(sum(pNormal.^2));
        [minDist, id] = min(distance);
        if minDist > DIST_THRESHOLD
            %disp(['Line ' num2str(doubletId) ' does not cut plane']);
            doCutAll = 0;         
            pointId = pointId + increment;            
            pointList(i) = 0;
            pointArray(i, :) = [0 0 0];
        else
            pointList(i) = id;
            pointArray(i, :) = oxyzi(id,:);        
        end
    end
end

varargout{1} = pointArray;
if nargout == 2
    varargout{2} = pointList;
end
   
