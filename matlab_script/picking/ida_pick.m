% 20071003 add auto_invert variant
% Picking IDA using a plane perpendicular to the microtuble

period = 960;
pixel_size = 6.8571;
variant_no = 4;

% Prepare the flagella
fid = fopen('list_tetra.txt', 'rt');
c = textscan(fid, '%s %s');
fclose(fid);

doc_name = 'doc_total2_tetra_';
doc_macm = 'doc_macm_tetra_';
doc_path = '../tetra';
star_path = '../tetra';

filament_list = [52:60];
mtb_list = cell(length(filament_list),1);
aln_list = cell(length(filament_list),1);
mtb_curves = cell(length(filament_list),1);
mtb_lens = cell(length(filament_list),1);


for i = 1:length(filament_list)
	mtb_list{i} = [c{2}{filament_list(i)+1}];
	aln_list{i} = [doc_name num2str(sprintf('%0.3d', filament_list(i))) '.spi'];
	[oxyzi, len] = fit_mtb_line([star_path '/' mtb_list{i} '.star'], [doc_path '/' aln_list{i}]);
	mtb_curves{i} = oxyzi;
	mtb_lens{i} = len;
	plot3(oxyzi(:,1), oxyzi(:,2), oxyzi(:,3), 'b-')	
    axis equal
    axis([0 1700 0 2048 0 400])
	view(10, 50)
	hold on
    %pause
end

% TODO pick up a point that is for sure in the range of the flagella
% Calculate a plane normal to the first mtb by calculate the least square line
% through the middle point
start_points = cell(length(filament_list),1);
start_ind = cell(length(filament_list),1);
pick_inds = cell(length(filament_list),1);

%point_ind = 2500;
point_ind = floor((1 + size(mtb_curves{1},1))/2);
start_points{1} = mtb_curves{1}(point_ind,:);
start_ind{1} = point_ind;
adj_points = mtb_curves{1}(point_ind-5:point_ind+5,:);

line = fitline3d(adj_points');
p_normal = diff(line,1,2);
d = - sum(p_normal'.*start_points{1});


% Finding nearest point from other line to the plane
for i = 2:length(filament_list)
	oxyzi = mtb_curves{i};
	rep_pn = repmat(p_normal',size(oxyzi,1),1);
	distance = abs(sum(oxyzi.*rep_pn,2) + d)/sqrt(sum(p_normal.^2));
	[min_d, ind] = min(distance);
    if min_d > 2
        disp(['Line ' num2str(i) ',' mtb_list{i} ' does not cut plane']);
    end
	start_points{i} = oxyzi(ind,:);
	start_ind{i} = ind;
end

% Plot to check
points = cat(1, start_points{:});
plot3(points(:,1), points(:,2), points(:,3), 'ro-');

% Start forward & backward pick point, & write to star file
for i = 1:length(filament_list)
    oxyzi = mtb_curves{i};
    len = mtb_lens{i};
    doInvert = 0;
    pick_inds{i} = ida_bf_pick(len*pixel_size, start_ind{i}, period, variant_no);
    aln_params = load([doc_path '/' doc_macm sprintf('%0.3d', filament_list(i)) '.spi']);
    disp(filament_list(i))
    if (aln_params(3) < 0 || aln_params(3) > 180)
        doInvert = 1;
    end

    for var_ind = 1:variant_no
        selected_ind = pick_inds{i}{var_ind};
        data = [oxyzi(selected_ind,1)' ; oxyzi(selected_ind,2)' ; oxyzi(selected_ind,3)']';
        if (doInvert)
            if (var_ind == 2)
                disp(var_ind)
                write_star_file(selected_ind, round(data), [star_path '/' mtb_list{i} 'ida_v' num2str(4) '.star'])
            elseif (var_ind == 4)
                write_star_file(selected_ind, round(data), [star_path '/' mtb_list{i} 'ida_v' num2str(2) '.star']);
            else
                write_star_file(selected_ind, round(data), [star_path '/' mtb_list{i} 'ida_v' num2str(var_ind) '.star']);
            end
        else
            write_star_file(selected_ind, round(data), [star_path '/' mtb_list{i} 'ida_v' num2str(var_ind) '.star'])
        end
    end
end

% Plot ida to visualize
hold on
var_ind = 4;
for i = 1:length(filament_list)
    selected_ind = pick_inds{i}{var_ind};
    oxyzi = mtb_curves{i};
    data = [oxyzi(selected_ind,1)' ; oxyzi(selected_ind,2)' ; oxyzi(selected_ind,3)']';
    plot3(data(:,1), data(:,2), data(:,3),'ro')
    hold on
    % Connect line together
end

% Print graph

%set(gcf,'Unit', 'pixels', 'Position', [0 0 600 900]);
%set(gca, 'YTick', 0:500:2000)
%box on, grid on
%set(gcf, 'PaperPositionMode', 'auto')
%print(gcf, '-r0', 'fla_xz_slice.tif', '-dtiff');
