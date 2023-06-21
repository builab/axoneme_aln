function new_origins = pick_mtb_2d_ida(origins, periodicity, dim, var_no)
% PICK_MTB_2D_IDA auto pick points on mtb based on a few points with a
% specified periodicity.
%   new_origins = pick_mtb_2d_ida(origins, periodicity)
% Parameters
%  IN
%   origins 			origins of a few points (from .star file)
%   periodicity     	periodicity of newly picked points (in pixels)
%	 dim					dimension to do interpolation
%  OUT
%   new_origins origins from fitted with specified periodicity

if nargin < 3
    dim = 2;
    var_no = 4;
end

if nargin < 4
	var_no = 4;
end

start = 1;
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

pick_ind = ida_bf_pick(len, start, periodicity, var_no);

for var_ind = 1:var_no
     new_origins{var_ind} = oxyi(pick_ind{var_ind}, :);
end

