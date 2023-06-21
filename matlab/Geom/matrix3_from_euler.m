function m = matrix3_from_euler(euler_angle)
% MATRIX3_FROM_EULER convert 3 euler angles (in degree) to rotational matrix
%   M = MATRIX3_FROM_EULER([PHI THETA PSI])
% Phi, theta, psi are given in degree
% Date: 11/01/2007

psi = deg2rad(euler_angle(3));
theta = deg2rad(euler_angle(2));
phi = deg2rad(euler_angle(1));

r_psi = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];

r_theta = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];

r_phi = [cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1];

m = r_psi*r_theta*r_phi;
