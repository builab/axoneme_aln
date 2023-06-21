function ang = angle_btw_pts(pts1, pts2, pts3)
% ANGLE_BTW_PTS returns angle in degree between 3 points
%   ang = angle_btw_pts(pts1, pts2, pts3)
% Use specially for fitting microtubule
% HB 20080117

v1 = pts2 - pts1;
v2 = pts3 - pts2;
% normalize
v1 = v1./sqrt(sum(v1.^2));
v2 = v2./sqrt(sum(v2.^2));
ang = real(acos(sum(v1.*v2)));
ang = ang*180/pi;
