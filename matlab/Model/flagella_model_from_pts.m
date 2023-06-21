function flagella  = flagella_model_from_pts(ptsList, doublet_list, flagDirect, sortDim, smoothing_limit, pixelSize)
% FLAGELLA_MODEL_FROM_PTS calculate flagella model from points
%   flagella  = flagella_model_from_pts(ptsList, doublet_list, flagDirect, sortDim, smoothing_limit, pixelSize)
% Parameters
%  INPUT
%	ptsList 	structure contain 9 array of points {[N x 3], [N x 3] ...}
%	doublet_list	doublet list ([1 .. 9] or partial)
%	flagDirect	flagella direction 0 or 1
%	sortDim 		sorting dimension (usually Y(2))
%	smoothing_limit Factor to smooth line, see smoothen_line function
%	pixelSize	pixelSize of the data
%  OUTPUT
%	flagella		Model of flagella with 3 Euler angles & model
%
% HB 20110102
% 20110112 Add curvature estimation
% TODO replace the finding cutting plane with optimization of distance
% between normal plane and all the doublets with contrains to pickup the
% nearest to the middle part of the flagella.

ANGLE_INCR = 40;
INT_POINTS = 3000; % interpolation point specify in fit_mtb_line2
DIST_THRESH = 1; % threshold to consider as in the same plane
NO_PTS_AVG = 4;

if nargin < 5
    pixelSize = 1;
end


for doublet_id = doublet_list
    origins = ptsList{doublet_id};
    smoothen_origins = smoothen_line(origins, smoothing_limit, sortDim);
    [oxyzi, len] = fit_mtb_line2(smoothen_origins, sortDim, 5); % Fit spline line

    % Incorporating rotation angle
    rotang = mtb_init_rotang(origins, flagDirect);
    num_of_particles = size(origins, 1);
    flagella(doublet_id).OrigPoints = origins;
    flagella(doublet_id).Line = oxyzi;
    flagella(doublet_id).Length = len;
    if (floor(num_of_particles/2) <= NO_PTS_AVG + 1)
		flagella(doublet_id).RotAng = mean(rotang(1:end,:));
    else
    	flagella(doublet_id).RotAng = mean(rotang(floor(num_of_particles/2)-NO_PTS_AVG: floor(num_of_particles/2)+NO_PTS_AVG+1,:));
	 end
    flagella(doublet_id).IndRotAng = rotang; % Individual rotation angle for each particle
    flagella(doublet_id).SortDim = sortDim;
    flagella(doublet_id).SmoothingLimit = smoothing_limit;
    flagella(doublet_id).PixelSize = pixelSize;
    flagella(doublet_id).FlagDirect = flagDirect;
    flagella(doublet_id).Curvature = curvatureLine3d(origins)*pixelSize;
end

% Get the longest & draw
max_len = 0;
max_id = 0;
for doublet_id = doublet_list
    if flagella(doublet_id).Length(end) > max_len
        max_id = doublet_id;
        max_len = flagella(doublet_id).Length(end);
    end
end

% Drawing the cutting plane
% If does not cut all the microtuble -> iteratively drawing the normal plane
point_id = 1500;
increment = 10; 
direct = 1; % 1 = increase, -1 = decrease
doCutAll = 0;
iterStop = 0;


while (~doCutAll && ~iterStop)
   
    point = flagella(max_id).Line(point_id, :);
    adj_points = flagella(max_id).Line(point_id-5:point_id+5,:);
    line = fitline3d(adj_points');
    p_normal = diff(line,1,2);
    d = - sum(p_normal'.*point);
    points_id = cell(9,1);
    points = cell(9,1);
    points_id{max_id} = point_id;
    points{max_id} = point;

    doCutAll = 1;
    for doublet_id = doublet_list 
        oxyzi = flagella(doublet_id).Line;
        rep_pn = repmat(p_normal',size(oxyzi,1),1);
        distance = abs(sum(oxyzi.*rep_pn,2) + d)/sqrt(sum(p_normal.^2));
        [min_d, id] = min(distance);
        if min_d > DIST_THRESH            
            doCutAll = 0;
            if (point_id <  INT_POINTS - increment && direct == 1)
                 point_id = point_id + increment;
            elseif (point_id >=  INT_POINTS - increment) % Reset and go other way
                direct = -1;
                point_id = 1500; 
            elseif (direct == -1 && point_id > increment)
                point_id = point_id - increment;
            else
                iterStop = 1;
            end
            break;
        end
        points_id{doublet_id} = id;
        points{doublet_id} = oxyzi(id,:);
        flagella(doublet_id).CutPoint = id;
    end
end

if ~doCutAll
    disp(['Plane does not cut all lines']);
end

% Guessing psi angle
% Incorporating incomplete flagella
% Guessing incomplete flagella's psi angle by using +40 degree.
for doublet_id = doublet_list
    prev_doublet = doublet_id - 1;
    next_doublet = doublet_id + 1;
    if doublet_id == 1
        prev_doublet = 9;
    end
    if doublet_id == 9
        next_doublet = 1;
    end

    mat = matrix3_from_euler([flagella(doublet_id).RotAng(1:2) 0]);
    % For debugging only
    pts = mat*points{doublet_id}';
    plot3(pts(1), pts(2), pts(3), 'bx'); hold on; disp(pts(3))

    % If incomplete flagella, don't guess
    if isempty(find(doublet_list == prev_doublet)) || isempty(find(doublet_list == next_doublet))
        flagella(doublet_id).RotAng(3) = 0;
    else
        pts1 = mat*points{prev_doublet}';
        pts2 = mat*points{next_doublet}';

        v = (pts2 - pts1)';
        v = v/sqrt(sum(v.^2));

        % Guessing angle
        flagella(doublet_id).RotAng(3) = atan2(v(1), -v(2))*180/pi;
        %disp(flagella(doublet_id).RotAng(3))
    end
end

% Guessing angle for incomplete flagella
if length(doublet_list) < 9
    for doublet_id = doublet_list
        prev_doublet = doublet_id - 1;
        next_doublet = doublet_id + 1;
        if doublet_id == 1
            prev_doublet = 9;
        end
        if doublet_id == 9
            next_doublet = 1;
        end

        if isempty(find(doublet_list == prev_doublet)) && ~isempty(find(doublet_list == next_doublet))
            flagella(doublet_id).RotAng(3) = flagella(next_doublet).RotAng(3) - ANGLE_INCR;
        elseif isempty(find(doublet_list == next_doublet)) && ~isempty(find(doublet_list == prev_doublet))
            flagella(doublet_id).RotAng(3) = flagella(prev_doublet).RotAng(3) + ANGLE_INCR;
        end

    end
end

% Fill in the individual doublet
for doublet_id = doublet_list
    flagella(doublet_id).IndRotAng(:,3) = ones(size(flagella(doublet_id).IndRotAng(:,3)))*flagella(doublet_id).RotAng(3);
end
