function r=radiusFrom3Pts(p1, p2, p3)
%RADIUSFROM3PTS calculates the radius of the circle going through three points
% 	function r=radiusFrom3Pts(pt1, pt2, pt3)
%PARAMETERS
% IN
%  pt, pt, pt the points [x y z]
% OUT
%  r radius of the circle
%Algorithm http://en.wikipedia.org/wiki/Radius
%  r = |P1 - P3|/2sin(theta) with theta = angle <P1P2P3>
%HB 2010/01/07 Tested with single point
%TODO working with array

r = sqrt(sum((p1-p3).^2, 2))./(2*sin(angleFrom3Pts(p1, p2, p3)));

function angle = angleFrom3Pts(p1, p2, p3)

v1 = p1 - p2;
v2 = p3 - p2;

v1 =normalize3d(v1);
v2 =normalize3d(v2);

angle = acos(dot(v1, v2, 2));

function vn = normalize3d(v)
%NORMALIZE3D normalize a 3D vector
%
%   V2 = normalize3d(V);
%   return the normalization of vector V, such that ||V|| = 1. Vector V is
%   given in vertical form.
%
%   When V is a Nx3 array, normalization is performed for each row of the
%   array.
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

%   HISTORY
%   30/11/2005  : correct a bug

n = sqrt(v(:,1).*v(:,1) + v(:,2).*v(:,2) + v(:,3).*v(:,3));
vn = v./[n n n];