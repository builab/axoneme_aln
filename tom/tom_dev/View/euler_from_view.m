function [phi theta psi] = euler_from_view(x, y, z, angle)
% EULER_FROM_VIEW from bsoft
% 12/01/07

theta = acos(z);

if abs(x) > 1e-6 || abs(y) > 1e-6
	phi = atan2(y, x);
else
	phi = 0;
end

psi = angle_set_negPi_to_Pi(angle - phi);
