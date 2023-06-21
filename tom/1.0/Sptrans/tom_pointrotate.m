function r = tom_pointrotate(r,phi,psi,the)
% TOM_POINTROTATE rotates point (= 3d vector)
%
%   r = tom_pointrotate(r,phi,psi,the)
%
%   A vector in 3D is rotated around the origin = [0 0 0]. The puropose is
%   for example to predict the location of a point in a volume after
%   rotating it with tom_rotate3d. Take care that the coordinates are with
%   respect to the origin!
%
%   R       3D vector - e.g. [1 1 1 ]
%   PHI     Euler angle - in deg.
%   PSI     Euler angle - in deg.
%   THE     Euler angle - in deg.
%
% EXAMPLE
%   r = [1 1 1]
%   r = tom_pointrotate(r,10,20,30)
%
% SEE ALSO
%   TOM_ROTATE3D, TOM_ROTATE2D
%
% 08/01/03 FF
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


phi = phi/180*pi;psi = psi/180*pi;the = the/180*pi;
%drehung um z
matr = [cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0;0 0 1];
%drehung um x
matr = matr*[1 0 0 ; 0 cos(the) -sin(the); 0 sin(the) cos(the)];
%drehung um phi
matr = matr*[cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0;0 0 1];
r = matr*r';
r=r';