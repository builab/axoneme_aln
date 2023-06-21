function tom_sortseries(pathname, newname,newextension)

% TOM_SORTSERIES sorts EM-files by tiltangle
%
%    Copies and sorts series of EM-Image Files (V-Format)
%    useful to sort tiltseries in ascending tilt-angle order.
%    TOM_SORTSERIES reads an entire directory!
%    All images are also checked for x-rays by TOM_XRAYCORRECT.
%
%    Syntax:
%             tom_sortseries(source_path, new_path_and_name,extension)
%              
%    Example: tom_sortseries('./tmp/','./new_tmp/new_','.em');
%
%             tom_sortseries         
%               opens two fileselect-boxes for source and destination
%
%    08/07/02 SN
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


if nargin <1 
[pathname] = uigetdir(pwd,'Select the source-directory of your tiltseries');
if isequal(pathname,0) disp('Cancelled.'); return; end;
[filename pathname_out] = uiputfile({'*.*'}, 'Select path and name of the sorted tiltseries (.em is added)');
if isequal(filename,0) | isequal(pathname_out,0) disp('Cancelled.'); return; end;
newextension='.em';
newname=[pathname_out filename];
pathname=[pathname '\'];
end;

d=dir(pathname);
angles=zeros((size(d,1)-2),1);
laufx=0;
for lauf=3:(size(d,1))
    if (tom_isemfile([pathname d(lauf).name])==1)
        laufx=laufx+1;
        em=tom_reademheader([pathname d(lauf).name]);
        angles(laufx)=em.Header.Tiltangle;
    else    
        laufx=laufx+1;
        angles(laufx)=-9999; %just a dummy Value to keep the index in the right order :-)
    end;
   
end;
[y,Index]=sort(angles);
lauf2=1;
for lauf=1:(size(angles,1))
    if (tom_isemfile([pathname d(Index(lauf)+2).name]) == 1)
        newemname=[newname num2str(lauf2) newextension];
        %    dos(['copy ' path d(Index(lauf)+2).name ' ' newemname]);
        i=tom_emread([pathname d(Index(lauf)+2).name]);
        disp([pathname d(Index(lauf)+2).name ' >> ' newemname ' ']);
        o.Value=tom_xraycorrect(i.Value); 
        %    o.Value=i.Value; 
        disp('correcting x-rays with a std_dev of 10 (SN)');
        o.Header=i.Header;
        tom_emwrite(newemname,o);
        lauf2=lauf2+1;    
    end;
    
end;

