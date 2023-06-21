function im=tom_circle(radius);
%TOM CIRCLE generates a circle
%   IM=TOM_CIRCLE(radius) generates a circle.It is required only one input, which 
%   is the radius of the circle.The Output of this function is a matrix that contains
%   the generated circle and its dimensions are (2*radius+1)x(2*radius+1).
%
%
%   Example 
%  ---------
%
%       im=tom_circle(3)
%
%
%                           0     0     0     1     0     0     0
%                           0     1     1     1     1     1     0
%                           0     1     1     1     1     1     0
%                   im =    1     1     1     1     1     1     1
%                           0     1     1     1     1     1     0
%                           0     1     1     1     1     1     0
%                           0     0     0     1     0     0     0
%
%
%   See also TOM_SPHERE, TOM_ERROR
%       
%
%   08/09/02    AL
     
center=radius+1;
lims=[1 2*radius+1];
[x,y]=meshgrid(lims(1):lims(2));
im=sqrt((x-center).^2+(y-center).^2)<=radius;