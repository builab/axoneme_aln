function [oxyzi, len] = fit_mtb_line2(datapoints, dim, tolerance)
% Fit a spline line on to a set of points (robust)
%   [oxyzi, len] = fit_mtb_line2(datapoints, dim, tolerance)
% Parameters
%   datapoints original data points
%   dim dimension to sort data
%   tolerance tolerance angle for checking, (default = 5)
%   oxyzi interpolated line
%   len cummulative length of the interpolated line
% Algorithm
%   Using angle check, angle between 2 consecutive vectors is supposed to
%   be 0. Checking angle less than a limit 5 degree eliminate bad points.
%   Then iteratively testing points & adding back to the curve
%
% HB 20080122 (Not tested)

if nargin < 3
    tolerance = 5;
end

smoothen_points = smoothen_line(datapoints, 15, 2);

% Calculating vectors
vector01 = [0 0 0; diff(smoothen_points, 1, 1)];
vector02 = [diff(smoothen_points, 1, 1) ; [0 0 0]];

% Normalize vectors
vector01_len = sqrt(sum(vector01.^2,2));
vector02_len = sqrt(sum(vector02.^2,2));

for i = 1:3
    vector01(:,i) = vector01(:,i)./vector01_len;
    vector02(:,i) = vector02(:,i)./vector02_len;
end

% Angle between consecutive vectors
angles = acos(sum(vector01.*vector02,2));
len = length(angles);
angles = angles.*180/pi;
angles(1) = angles(2);
angles(len) = angles(len-1);

indx = angles > 90;
angles = angles - indx*180;

outlier = abs(angles) > tolerance;
bad_pts = find(outlier == 1)';

for i = bad_pts
    good_pts = find(outlier == 0)';
    prev_list = good_pts(good_pts < i);
    next_list = good_pts(good_pts > i);

    if isempty(prev_list)
       prev_pts = next_list(1); 
       next_pts = next_list(2);
       ang = angle_btw_pts(smoothen_points(i,:), smoothen_points(prev_pts,:), smoothen_points(next_pts,:));
    elseif isempty(next_list)
       next_pts = prev_list(length(prev_list)-1); 
       prev_pts = prev_list(end);
       ang = angle_btw_pts(smoothen_points(prev_pts,:), smoothen_points(next_pts,:), smoothen_points(i,:));
    else
       prev_pts = prev_list(end);
       next_pts = next_list(1);
       ang = angle_btw_pts(smoothen_points(prev_pts,:), smoothen_points(i,:), smoothen_points(next_pts,:));
    end

    if ang <= tolerance 
        outlier(i) = 0;    
    end
    
end

good_pts = find(outlier == 0)';

corr_pts = smoothen_points(good_pts,:);
[oxyzi, len] = fit_mtb_line(corr_pts, dim);

