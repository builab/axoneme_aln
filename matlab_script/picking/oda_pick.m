function [points, selected_indx] = oda_pick(oxyzi, start_indx, period, is_selected, origin)
% ODA_PICK picks oda on a fitted line
%   [points, pick_ind] = oda_pick(oxyzi, start_indx, period, is_selected)
% Parameters
%   oxyzi Nx3 fitted curve
%   start_indx index of starting point
%   period periodicity
%   is_selected only pick points near original points
%   origins original point
% HB 20080128


% determine the length of the curve
len = [0 cumsum(sqrt(sum((diff(oxyzi, 1, 1)).^2,2)))']';

pick_ind = bf_pick(len, start_indx, period);

oxi = oxyzi(:,1);
oyi = oxyzi(:,2);
ozi = oxyzi(:,3);

indx = zeros(1,length(len));
indx(pick_ind) = 1;

selected_indx = indx;

if (is_selected)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Only pickup period near original picked up point
    box_limit_factor = 1.5;
    box_limit = box_limit_factor*period;

    for i = find(indx == 1)
        a = zeros(size(origin));
        a(:,1) = origin(:,1) - oxi(i);
        a(:,2) = origin(:,2) - oyi(i);
        a(:,3) = origin(:,3) - ozi(i);

        list_x = (abs(a(:,1)) < box_limit);
        list_y = (abs(a(:,2)) < box_limit);
        list_z = (abs(a(:,3)) < box_limit);
        list_xyz = list_x.*list_y.*list_z;

        adj_points = a(list_xyz==1, :);
        distance_i = sqrt(sum(adj_points.^2,2));

        if sum(distance_i < box_limit_factor*period) == 0
            selected_indx(i) = 0;
        end
    end
    selected_indx = selected_indx == 1;
else
    selected_indx = indx;
end

points = oxyzi(selected_indx, :);
