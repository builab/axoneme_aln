function tom_backproj3d(volume,image, angle_phi, angle_the, offset, mask)

% TOM_BACKPROJ3D performs a 3D backprojection
%    Function works in place, allocates no additional memory.
%
%   tom_backproj3d(volume,image, angle_phi, angle_the, offset)
%
%    Syntax:
%               volume      is a 3D volume (single)
%               image       is a 2D image (single)
%               angle_phi   is the projection angle phi
%               angle_the   is the projection angle the
%                           convention see Bronstein
%               offset      is a vector of length three       
%       
%    08/08/02 SN
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


if nargin < 5
     disp('tom_backproj3d: Not enough input parameters. No backprojection done!');
 end
if nargin == 5
     tom_backproj3dc(single(volume),single(image), angle_phi, angle_the, offset);
 end
if nargin == 6
     tom_backproj3dmaskc(single(volume),single(image), angle_phi, angle_the, offset,mask);
end
  
 
