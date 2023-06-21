function ccc = tom_ccc(a,b,flag)
% TOM_CCC calculates normalized 3d cross correlation coefficient
%
%   ccc = tom_ccc(a,b,flag)
%
% PARAMETERS
%   INPUT
%   A       array - 1d, 2d or 3d
%   B       array - dimsions as A
%   FLAG    canbe set to 'norm' for normalized CCC
%
%   OUTPUT
%   CCC     cross correlation COEFFICIENT
%
%   The cross correlation coefficient is calculated in real space, thus the
%   translation is NOT determined. If FLAG is 'norm', then the
%   normalized CCC is computed.
%
% EXAMPLE
%   im = tom_emread('proteasome.em');
%   ccc = tom_ccc(im.Value,im.Value,'norm');
%
% SEE ALSO
%   TOM_CORR, TOM_ORCD
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
%
%   last change
%   30.03.03 FF

if (nargin > 2)
%    if isequal(flag,'norm')
    a= a-mean(mean(mean(a)));
    b= b-mean(mean(mean(b)));
    ccc = sum(sum(sum(a.*b)))/sqrt(sum(sum(sum(a.*a)))*sum(sum(sum(b.*b))));
else
    ccf=sum(sum(sum(a.*b)));
end;