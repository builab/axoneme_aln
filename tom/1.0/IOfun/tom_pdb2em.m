function emmap = tom_pdb2em(pdbdata, pixelsize, dim)
%
%   emmap = tom_pdb2em(pdbdata, pixelsize, dim)
%
% INPUT
%
%   PDBDATA         expected as structure as derived from TOM_PDBREAD
%   PIXELSIZE       desired pixelsize in Angstrom
%   DIM             dimension of desired cube
%
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom


emmap = zeros(dim,dim,dim);
x = round([pdbdata.ATOM.X]/pixelsize)+ floor(dim/2);%interpolate coordinates on mesh of pixelsize 
y = round([pdbdata.ATOM.Y]/pixelsize)+ floor(dim/2);
z = round([pdbdata.ATOM.Z]/pixelsize)+ floor(dim/2);
atom = reshape([pdbdata.ATOM.AtomName],4,size([pdbdata.ATOM.AtomName],2)/4);
for iatom = 1:size(x,2)
    if ((x(iatom) > 0) &  (y(iatom) > 0) &  (z(iatom) > 0))
        if (strmatch(atom(2,iatom),'C') )  
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+6;
        elseif (strmatch(atom(2,iatom),'N')) 
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+7;
        elseif (strmatch(atom(2,iatom),'O')) 
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+8;
        elseif (strmatch(atom(2,iatom),'H')) 
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+1;
        elseif (strmatch(atom(2,iatom),'P')) 
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+15;
        elseif (strmatch(atom(2,iatom),'S')) 
            emmap(x(iatom),y(iatom),z(iatom))=emmap(x(iatom),y(iatom),z(iatom))+16;
        end;
    end;
end;