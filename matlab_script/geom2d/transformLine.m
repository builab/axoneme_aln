function dest = transformLine(line, trans)
%TRANSFORMLINE tranform a line with an affine transform
%
%   LINE2 = transformLine(PT1, TRANS).
%   where LINE1 has the form [x0 y0 dx dy], and TRANS is a transformation
%   matrix, return the line transformed with affine transform TRANS. 
%
%   Format of TRANS can be one of :
%   [a b]   ,   [a b c] , or [a b c]
%   [d e]       [d e f]      [d e f]
%                            [0 0 1]
%
%   LINE2 = transformLine(LINES, TRANS) also wotk when LINES is a [N*4]
%   array of double. In this case, LINE2 has the same size as LINE.
%
%   See also :
%   transformPoint, translation, rotation, translation
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   02/03/2007: rewrite function


% isolate points
points1 = line(:, 1:2);
points2 = line(:, 1:2) + line(:, 3:4);

% transform points 
points1 = transformPoint(points1, trans);
points2 = transformPoint(points2, trans);

dest = createLine(points1, points2);
