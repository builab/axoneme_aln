function euler = euler_from_matrix3(mat)
%EULER_FROM_MATRIX3 convert a rotational matrix to euler angle
% Source: Bsoft
% Date: 16/01/07

SMALLFLOAT = 1e-14;
M_PI = 3.14159265358979323846264338327950288;

theta = acos(mat(9));
if theta < SMALLFLOAT
	phi = 0;
	phi = atan2(-mat(2),mat(1));
elseif abs(theta - M_PI) < SMALLFLOAT
	phi = 0;
	psi = atan2(mat(2), -mat(0));
else
	phi = atan2(mat(6), mat(3));
	psi = atan2(mat(8), -mat(7));
end

euler = [rad2deg(phi) rad2deg(theta) rad2deg(psi)];
