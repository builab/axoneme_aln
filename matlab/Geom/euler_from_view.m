function [phi, theta, psi] = euler_from_view(x, y, z, angle)
% EULER_FROM_VIEW from bsoft
%		[phi, theta, psi] = euler_from_view(x, y, z, angle)
%
% 12/01/07 HB

theta = acos(z);

if abs(x) > 1e-6 || abs(y) > 1e-6
	phi = atan2(y, x);
else
	phi = 0;
end

psi = angle_set_negPi_to_Pi(angle - phi);
