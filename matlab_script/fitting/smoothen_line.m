function new_datapoints = smoothen_line(datapoints, smooth_limit, dim)
% SMOOTHEN_LINE smoothen data by average point too near, deal with
% triplicate and duplicate data points
%   new_datapoints = smoothen_line(datapoints)
% Parameters
%   datapoints      original data points
%   new_datapoints  smoothened data points
%   dim             sorting dimension (1=x, 2=y, 3=z)
%
% HB 20080116

if nargin < 3
    dim = 2;
end
distance = [0 sqrt(sum((diff(datapoints, 1, 1)).^2,2))']';
smooth_index = distance  < smooth_limit;
smooth_index(1) = 0;

new_datapoints = [];
i = 2;
while (i <= size(datapoints,1))

    if smooth_index(i) == 1 
        if i < size(datapoints,1) && smooth_index(i+1) == 1 % triple duplicate
            new_datapoints = [new_datapoints ; (datapoints(i-1,:) + datapoints(i,:) + datapoints(i+1,:))/3];
            i = i+3;
        else
            new_datapoints = [new_datapoints ; (datapoints(i-1,:) + datapoints(i,:))/2];
            i=i+2;
        end
    else
        new_datapoints = [new_datapoints ; datapoints(i-1,:)];
        i=i+1;
    end
end

if smooth_index(size(datapoints,1)) ~= 1
    new_datapoints = [new_datapoints ;  datapoints(size(datapoints,1),:)];
end

%Sort the curve along dimension
[tmp, sort_indx] = sort(new_datapoints(:,dim));

new_datapoints = new_datapoints(sort_indx, :);