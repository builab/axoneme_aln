function mag = getMagnification(mode)
% Get magnification of the each mode
% 	mag = getMagnification(mode)
% Parameters
%	IN
%		mode can be 'search', 'focus', 'exposure'
%	OUT
%		corresponding magnification

% Temporary
switch mode
    case 'search' 
        mag = 5600;
    case 'focus'
        mag = 80000;
    case 'exposure'
        mag = 27500;
    otherwise
        disp('unknown mode')
        mag = -1;
end