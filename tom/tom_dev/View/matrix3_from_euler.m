function m = matrix3_from_euler(euler)
% MATRIX3_FROM_EULER convert 3 euler angles to rotational matrix
%   M = MATRIX3_FROM_EULER([Phi Theta Psi])
% Phi, theta, psi are given in degree
% Date: 11/01/2007

psi = deg2rad(euler(1));
theta = deg2rad(euler(2));
phi = deg2rad(euler(3));

r_psi = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];

r_theta = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];

r_phi = [cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1];

m = r_psi*r_theta*r_phi;
