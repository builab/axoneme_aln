function [out,n]=tom_hist3d(in)

% TOM_HIST3D calculates a histogram of 3D data.
%
%  [out,n]=tom_hist3d(in)
%
%  Calculates the histogram for 3D data, using the
%  matlab hist function.
%
% PARAMETERS
%
%   INPUT
%   in       3D array
%
%   OUTPUT
%   out      array with channel occupancy values
%   n        array with correspnoding values of each column
%
% See also
%  HIST, HISTC
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
%
%
%   01/02/03 SN
%   last change 03/28/03 FF
%



[out n]=hist(reshape(double(in),1,size(in,1).*size(in,2).*size(in,3)),100);
% auf out: Kanalnr. vs. Haeufigkeit, auf n: Kanalnr. -> Value
