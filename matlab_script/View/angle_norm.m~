function anglen = angle_norm(angle)
% ANGLE_NORM normalize angle (vector) to -180-180 range
% 	anglen = angle_norm(angle)
% Parameter
%	Input
%		vector angle in degree
%	Output
%		anglen in -180 to 180
% HB 20080408

anglen = mod(angle, 360);

neg_indx = anglen <= -180;
anglen(neg_indx) = anglen(neg_indx) + 360;

pos_indx = anglen > 180;
anglen(pos_indx) = anglen(pos_indx) - 360;