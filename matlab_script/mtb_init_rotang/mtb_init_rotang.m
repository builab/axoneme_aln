function rotang = mtb_init_rotang(points, sign)
% MTB_INIT_ROTANG calculate microtubule initial rotation angle.
%   rotange = mtb_init_rotang(points, sign)
% It is much more useful if the coordinate of points is calculated from
% fitting.
% Parameters
%   points  Nx3 array of initial points
%   sign    direction of the microtubule (0: proximal end -> distal end in
%   direction of increasing y, 1: proximal end -> distal end in direction
%   of decreasing y
%   rotang  calculated fitting angle to rotate the microtubule into top view
%   position.
% Algorithm
%   Calculate vectors of consecutive points, normalized to unit vectors & 
%   calculate the angles based on phi = atan2(y,x), theta = acos(z)
%   
% HB 20080129

if (nargin < 2)
    sign = 0;
end

vec = diff(points, 1, 1);
vec = [vec(1,:) ; vec]; % For the first point, using the 2nd vector 
vec_len = sqrt(sum(vec.^2,2));
vec_norm = vec./repmat(vec_len,1,3); 

if (sign == 1)
    vec_norm = -vec_norm;
end

rotang = zeros(size(vec_norm));
rotang(:,1) = atan2(vec_norm(:,2),vec_norm(:,1));
rotang(:,2) = acos(vec_norm(:,3));

rotang = rotang*180/pi;
