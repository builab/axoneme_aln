function [oxyzi, len] = fit_mtb_line(datapoints, dim)
% Fit a spline line on to a set of points
%   [oxyzi, len] = fit_mtb_line(datapoints, dim)
% Parameters
%   datapoints original data points
%   dim dimension to sort data
%   oxyzi interpolated line
%   len cummulative length of the interpolated line
%
% HB rewrite 29/11/2007
% 20070116 use smoothen_line (Not yet test)

if nargin < 2
    dim = 2; % default dimension y
end

%Sort the curve along y
[ind_var, sort_indx] = sort(datapoints(:,dim));

if dim == 1
    rdim = [2 3];
elseif dim == 2
    rdim = [1 3];
else
    rdim = [1 2];
end
    
% Prepare data for curve fitting cubic spline
dep_var = datapoints(sort_indx, rdim)';

% Cubic spline interpolation for noisy data
ind_var_interp = linspace(min(ind_var), max(ind_var), 3000);
dep_var_interp = spline(ind_var, dep_var, ind_var_interp);

var_interp_01 = dep_var_interp(1, :);
var_interp_02 = dep_var_interp(2, :);

if dim == 1
    oxyzi = [ind_var_interp; var_interp_01 ; var_interp_02]';
elseif dim == 2
    oxyzi = [var_interp_01 ; ind_var_interp ; var_interp_02]';
else
    oxyzi = [var_interp_01 ; var_interp_02  ; ind_var_interp]';
end

len = [0 ; cumsum(sqrt(sum(diff(oxyzi, 1, 1).^2,2)),1)];

