function tom_makefun
%Script to compile C files.
%
%SYNTAX
%tom_makefun
%
%DESCRIPTION
%Compile C file. Create .dll on windows, .mexglx under linux
%
%EXAMPLE
%tom_makefun
%
%SEE ALSO
%MEX, 
%
%Copyright (c) 2004
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 05/12/04 FF
%

cd IOfun/
mex tom_emwriteinc.c  
mex tom_emreadinc.c
cd ..
cd Reconstruction/
mex tom_backproj3dc.c 
mex tom_dist.c
cd ..
cd  Sptrans/
mex tom_rotatec.c 
cd ..
