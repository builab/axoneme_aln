function elli = fit_ellipse_flagella_model(model, doubletList, lowerBound, upperBound, doDraw)
% FIT_ELLIPSE_FLAGELLA_MODEL fit ellipse on the cross section of the flagellar model
% 	ellip = fit_ellipse_flagella_model(model, doubletList, lowerBound, upperBound, doDraw)
% PARAMETERS
%  IN
%	model		flagella model output from function flagella_model_from_pts
%   doubletList doubletList [ 1 .. 9] (no partial)
%	lowerBound	lowerBorder in the sorting dimension
%	upperBound	upperBorder in the sorting dimension to calculate 
%   doDraw      fit the ellipse in figure (1 or 0)
%  OUT
%	ellip		elliptical parameter [a b c d e f] (see fit_ellipse
%	function)
% HB 20110107
% Please check the nearest neighbor option

if nargin < 5
    doDraw = 0;
end

[pointArray, pointList] = cross_section_from_flagella_model(model, doubletList, lowerBound, upperBound);
for i = doubletList
    if pointList(i) == 0
        disp('Does not contain all 9 doublets')
        elli = [];
        return;
    end
end

tfmCuttingPoints = zeros(length(doubletList), 2); 

for i = 1:length(doubletList)
    doubletId = doubletList(i);
    mat = matrix3_from_euler([model(doubletId).RotAng(1:2) 0]);    
    pts_tfm = (mat*pointArray(i, :)')';    
    tfmCuttingPoints(i,:) = pts_tfm(1:2);    
end

if (doDraw)
    plot(tfmCuttingPoints(:,1), tfmCuttingPoints(:,2), 'b*');
    elli = fit_ellipse(tfmCuttingPoints(:,1), tfmCuttingPoints(:,2), gca);
else
    elli = fit_ellipse(tfmCuttingPoints(:,1), tfmCuttingPoints(:,2));
end