function I_out=tom_imadj(I,fmin,fmax)
%TOM_IMADJ   
%   07/26/02 changed function of AF
%   FF
%   scales image between 0 and 1, range can be constrained by fmin and fmax

error(nargchk(1,3,nargin))
%Use of the hole dynamic range per default
fmaxt = max(max(max(I)));
fmint = min(min(min(I)));

if (nargin < 3)
    fmax = fmaxt;
end;
if (nargin < 2)
    fmin = fmint;
end;
if (fmin < fmint)
    disp(['given minimum (' num2str(fmin) ') smaller than minimum value in image (' num2str(fmint) ')' ])
    fmin = fmint;
end;
if (fmax > fmaxt)
    disp(['given maximum (' num2str(fmax) ') bigger than maximum value in image (' num2str(fmaxt) ')' ])
    fmax = fmaxt;
end;

%Justify Image between 0 and 1
I=tom_limit(I,fmin, fmax);
I_out = (I-fmin)/(fmax-fmin);

