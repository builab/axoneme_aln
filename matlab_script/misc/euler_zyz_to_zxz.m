function e = euler_zyz_to_zxz(euler)
% EULER_ZYZ_TO_ZXZ converts zxz convention to zyz convention
%   e = euler_zyz_to_zxz(euler)
% IN
%   euler   [phi theta psi] in zyz convention (in degree)
% OUT
%   e       [phi' theta' psi'] in zxz convention
% HB 20110512
% See also euler_zxz_to_zyz
% TODO check this more carefully

e = [-euler(1) euler(2) -euler(3)] + [90 0 -90];


