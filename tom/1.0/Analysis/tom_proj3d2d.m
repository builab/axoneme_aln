function x2d=tom_proj3d2d(x3d,Phi,The)

% TOM_PROJ3D2D projects a 3d point on a 2d plane
%    Phi,The are azimuth and elevation
%
% SN, 05/02/04

% x4d=x3d;
% x4d(4)=1;
% 
% A=viewmtx(az,el);
% 
% x2d=(A*x4d')';
% x2d=x2d(1:3);
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
    


    Psi=Phi-90;

     Phi=90-Phi;
     
     Phirad=Phi.*pi./180;
     Psirad=Psi.*pi./180;
     Therad=The.*pi./180;
     
     Cos_phi = cos(Phirad);
     Sin_phi = sin(Phirad);
     Cos_psi = cos(Psirad);
     Sin_psi = sin(Psirad);
     Cos_the = cos(Therad);
     Sin_the = sin(Therad);
     
     rotation_matrix(1,1)=  (Cos_psi*Cos_phi) -(Cos_the*Sin_psi*Sin_phi);
     rotation_matrix(2,1) = (Sin_psi*Cos_phi) +(Cos_the*Cos_psi*Sin_phi);
     rotation_matrix(3,1) = (Sin_the*Sin_phi);
     rotation_matrix(1,2) = (- Cos_psi*Sin_phi) -(Cos_the*Sin_psi*Cos_phi);
     rotation_matrix(2,2) = (- Sin_psi*Sin_phi) +( Cos_the*Cos_psi*Cos_phi);
     rotation_matrix(3,2) = (Sin_the*Cos_phi);
     rotation_matrix(1,3) = (Sin_the*Sin_psi);
     rotation_matrix(2,3) = (- Sin_the*Cos_psi);
     rotation_matrix(3,3) = (Cos_the); 

     x3d_new=(rotation_matrix*x3d')';

     % projection in z
     x2d=x3d_new(1:2);