function c=tom_norm(a,scf)
%TOM_NORM  Normalizes the image values between 0 and Scaling Factor (scf)
%   C=TOM_NORM(A,SCF) This function normalizes the values of the input image A between 0 and
%   Scaling Factor, SCF. The output is the image A with normalized values
%
%   Example
%  ----------
%
%       c=tom_norm(a,10)
%
%           10  1  19  8   5
%           12  9  17  10  10
%       a = 3   3  2   0   8
%           15  8  0   7   8
%           0   8  6   15  8
%
%           5.263   0.526   10.00   4.210   2.631
%           6.315   4.736   8.947   5.263   5.263
%       c = 1.578   1.578   1.056   0       4.210   
%           7.894   4.210   0       3.684   4.210
%           0       4.219   3.157   7.894   4.210
%
%
%
%   See also   TOM_MOVE, TOM_PEAK, TOM_LIMIT, TOM_FILTER
%
%   08/17/02   AL
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


a=a-min(min(min(a)));
c=scf*a/max(max(max(a)));