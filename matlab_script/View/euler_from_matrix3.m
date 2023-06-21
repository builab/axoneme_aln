function euler = euler_from_matrix3(mat)
%EULER_FROM_MATRIX3 convert a rotational matrix to euler angle
%	[phi, theta, psi] = euler_from_matrix3(mat)
% Source: Bsoft
% Date: 16/01/07

SMALLFLOAT = 1e-14;
M_PI = 3.14159265358979323846264338327950288;

theta = acos(mat(9));

if theta < SMALLFLOAT
	phi = 0;
	psii = atan2(-mat(2),mat(1));
elseif abs(theta - M_PI) < SMALLFLOAT
	phi = 0;
	psii = atan2(mat(2), -mat(1));
else
	phi = atan2(mat(6), mat(3));
	psii = atan2(mat(8), -mat(7));
end

phi = rad2deg(phi);
theta = rad2deg(theta);
psii = rad2deg(psii);

euler = [phi theta psii];