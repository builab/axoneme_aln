function  out=tom_symref2d(in,factor)

%   FF
%
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

out=ones(size(in)).*mean2(in);
for angle=0:(360./factor):359    
    out=(imrotate(in,angle,'bilinear','crop')+out)./2;
end

