function phantom=tom_phantom3d(phantomsize,type)

% tom_phantom3d creates a 3D phantom array 
%
%   phantom=tom_phantom3d(phantomsize,type)
%
%   Creates a sample volume for test purposes,
%   a so called phantom.
%
% PARAMETERS
%
%   INPUT
%    phantomsize    vector of 3D dimension 
%    type           'tripod' or 'mickey' defining the
%                   shapes in the volume
%
%   OUTPUT
%    phantom        3D array
%
% EXAMPLE
%    phantom = tom_phantom3d([32 32 32],'mickey');
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
%
% 01/02/03 SN
%

if isequal(type,'tripod')
    phantom=zeros(phantomsize);
    im=tom_sphere(phantomsize./8);    
    phantom=tom_paste(phantom,im,[phantomsize./4 phantomsize./4 phantomsize./2-phantomsize./16]);
    phantom=tom_paste(phantom,im,[phantomsize./4 phantomsize./2 phantomsize./2-phantomsize./16]);
    phantom=tom_paste(phantom,im,[phantomsize./2 phantomsize./4 phantomsize./2-phantomsize./16]);    
end;

if isequal(type,'mickey')
    phantom=zeros(phantomsize);
    head=tom_sphere(phantomsize./4);    
    head=head.*0.5;
    phantom=tom_paste(phantom,head,[round(phantomsize./2-(size(head,1)./2)) round(phantomsize./2-(size(head,1)./2)) round(phantomsize./2-(size(head,1)./2))]);
    phantom_add=zeros(phantomsize);
    ear=tom_sphere(phantomsize./8);    
    ear=ear.*0.6;
    phantom_add=tom_paste(phantom_add,ear,[round(phantomsize./2-(size(ear,1)./2)-(size(head,1)./2)) round(phantomsize./2-(size(ear,1)./2)-(size(head,1)./2)) round(phantomsize./2-(size(ear,1)./2))]);
    phantom_add=tom_paste(phantom_add,ear,[round(phantomsize./2-(size(ear,1)./2)-(size(head,1)./2)) round(phantomsize./2-(size(ear,1)./2)+(size(head,1)./2)) round(phantomsize./2-(size(ear,1)./2))]);
    nose=tom_sphere(phantomsize./10);    
    nose=nose.*0.7;
    phantom_add=tom_paste(phantom_add,nose,[round(phantomsize./2-(size(nose,1)./2)) round(phantomsize./2-(size(nose,1)./2)) round(phantomsize./2+(size(head,1)./3))]);
    phantom=phantom+phantom_add;
end;
