function out=tom_rotate(varargin)
%
% TOM_ROTATE performs a 2d or 3d rotation, depending on the input 
%   Note: This function works as an interface. The actual computation is done
%         in the C-Function tom_rotatec
%
% Syntax:
%   out=tom_rotate(in,[angle(s)],interp,[center]) 
%
% Input:
%   in                    :image or Volume as single !
%   angle(s)              :in=image  rotation angle
%                         :in=volume euler Angles [phi psi theta] 
%   interp                :interpolation only 'linear' implemented                     
%   center(optional)      :in=image  [centerX centerY]       
%                         :in=Volume [centerX centerY centerZ]
% Ouput:
%   out                   : Image rotated
%
% Example:
% im=tom_emread('pyrodictium_1.em');
% out=tom_rotate(single(im.Value),40,'linear',[256 256]);
%
% im=tom_emread('testvol.em');
% im=single(im.Value);
% out=tom_rotate(im,[30 20 95],'linear');
%       
%  12/04/04 FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom



switch nargin
    case 4,
        center = varargin{4};
        ip=varargin{3};
    case 3,
        ip=varargin{3};
        center = [ceil(size(varargin{1})./2)];%bug fixed for uneven dims - FF
    case 2,
        center = [ceil(size(varargin{1})./2)];%bug fixed FF
        ip = 'linear';
    otherwise
        disp('wrong number of Arguments');
        out=-1; return;
end;
%parse inputs
in = varargin{1};
euler_angles=varargin{2};


% allocate some momory 
out = single(zeros(size(in))); 

% call C-Function to do the calculations
tom_rotatec64bit(single(in),out,single([euler_angles]),ip,single([center]));

out = double(out);
