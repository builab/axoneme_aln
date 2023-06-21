% Adapt fit mtb curve to auto pick oda


% Star file
star_file = '/mol/ish/Data/20080429wt/wt12/Star/wt12_cp.star';
pixel_size = 0.68571; % nm 0.4988
period_nm = 32; % nm
sortDim = 2;
fittingType = 'line';
output_star = '/mol/ish/Data/Huy_tmp/cpc/star/wt12_cp.star';

origins = parse_star_file(star_file, 'origin');

[sorted_oy, sort_indx] = sort(origins(:,sortDim), 'ascend');
sorted_origins = origins(sort_indx, :);

new_origins = auto_fit_mtb(origins, period_nm/pixel_size, sortDim, fittingType);

plot3(new_origins(:,1), new_origins(:,2), new_origins(:,3), 'ro')
axis([1 2000 1 2000 1 300]);
view(10, 80);
box

write_star_file(star_file, round(new_origins), output_star);

exit;
%%%%%%%%%%%%%%%%%%%%%%
% Mass fit
%%%%%%%%%%%%%%%%%%%%%

for i = 1:9
    star_file = ['oda1_42_' num2str(i) '.star'];
    pixel_size = 0.4988; % nm 0.4988
    period_nm = 24; % nml
    output_star = ['oda1_42_' num2str(i) 'm.star'];

    % Grep content
    unix(['cat ' star_file ' | grep -P ''\s?[0-9](\s+\d+)+''  > star.txt']);
    star_content = load('star.txt');
    origins = star_content(:,3:5);

    [sorted_oy, sort_indx] = sort(origins(:,2), 'ascend');
    sorted_origins = origins(sort_indx, :);


    new_origins = auto_fit_mtb(origins, period_nm/pixel_size);
    write_star_file(star_file, round(new_origins), output_star);
end

