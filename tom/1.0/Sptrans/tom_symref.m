function volsym = tom_symref(vol,nfold)
% TOM_SYMREF does n-fold symmetrization of a 3D reference.
%
%   volsym = tom_symref(vol,nfold)
%
%   If a volume VOL is assumed to have a n-fold symmtry axis along z it can
%   be rotationally symmetrized using TOM_SYMREF
%
%  PARAMETERS
%
%  INPUT
%   VOL     3D volume to be symmterized
%   NFOLD   rotational symmetry along z (>= 2)
%
%  OUTPUT
%   VOLSYM  symmetrized volume
%   
%   07/28/03 FF
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

iangle = 360/nfold;
volsym=vol;
nphi = 360/nfold;
for ind = 2:nfold
    phi = nphi*(ind-1);
    volsym = volsym + double(tom_rotate(vol,[phi,0,0]));
end;
volsym = volsym/nfold;
