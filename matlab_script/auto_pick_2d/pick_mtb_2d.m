function new_origins = pick_mtb_2d(origins, periodicity, dim)
% PICK_MTB_2D auto pick points on mtb based on a few points with a
% specified periodicity.
%   new_origins = pick_mtb_2d(origins, periodicity, dim)
% Parameters
%  IN
%   origins 		origins of a few points (from .star file)
%   periodicity     	periodicity of newly picked points (in pixels)
%   dim			dimension to do interpolation
%  OUT
%   new_origins origins from fitted with specified periodicity

if nargin < 3
    dim = 2;
end

order = 2;

[sort_dim, sort_ind] = sort(origins(:,dim));

if dim == 1
	other_dim = origins(sort_ind, 2);
else
	other_dim = origins(sort_ind, 1);
end

p = polyfit(sort_dim, other_dim, order);

yi = linspace(sort_dim(1), sort_dim(end), 3000);
xi = polyval(p, yi);

if dim == 2
	oxyi = [xi ; yi]';
else
	oxyi = [yi ; xi]';
end

len = [0 ; cumsum(sqrt(sum(diff(oxyi, 1, 1).^2,2)),1)];

pick_ind = bf_pick(len, 1, periodicity);

new_origins = oxyi(pick_ind, :);

