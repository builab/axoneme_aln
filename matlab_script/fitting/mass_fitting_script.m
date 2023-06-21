% Demo file for picking ODA

fid = fopen('list_oda11.txt', 'rt');
c = textscan(fid, '%s %s');
fclose(fid);


for loop_ind = 1:length(c{1})


    star_path = '../oda11/star';
    aln_path = '../oda11/doc';

    star_file = [star_path '/' c{2}{loop_ind} '.star'];
    aln_file = [aln_path '/' 'doc_total2_' c{1}{loop_ind} '.spi'];
    output_star_file = [star_path '/' c{2}{loop_ind} 'm.star'];
    
    disp(c{1}{loop_ind})
    disp(star_file)
    disp(aln_file)

    period = 240;
    limit_factor = 3;
    pixel_size = 6.8571;

    % Load file & Fitting
    unix(['cat ' star_file ' | grep ''^[[:space:]]*[0-9]''  > star.txt']);
    unix(['cat ' aln_file ' | grep ''^[[:space:]]*[0-9]''  > aln.txt']);

    % Read aln_file
    star_content = load('star.txt');
    aln_content = load('aln.txt');

    origin = star_content(:,3:5);
    transform = aln_content(:,3:8);

    origin_new = transform_pts(origin, transform);
    smoothen_origins = smoothen_line(origin_new, 13); % Smoothen points with limit = 13
    [oxyzi, len] = fit_mtb_line2(smoothen_origins, 2, 5); % Fit spline line

    % Plot to check
    figure
    plot3(smoothen_origins(:,1), smoothen_origins(:,2), smoothen_origins(:,3), 'b.')
    axis([0 2048 0 2048 0 400]);
    view(10, 80);
    hold on
    plot3(oxyzi(:,1), oxyzi(:,2), oxyzi(:,3), 'r')
    box on

    % Picking good points on the line
    [coor, indx] = pick_good_pts(smoothen_origins, period/pixel_size, 4); % tolerance = 4

    % Find index of point on fitted line nearest to good points
    coor_vec = repmat(coor,size(oxyzi,1),1);
    distance = sqrt(sum((coor_vec-oxyzi).^2, 2));
    [val, min_indx] = min(distance);

    % Pick oda
    [data, selected_indx] = oda_pick(oxyzi, min_indx, period/pixel_size, 1, origin_new);


    % Check
    hold on
    plot3(data(:,1), data(:,2), data(:,3), 'ro');
    hold off

    write_star_file(star_file, round(data), output_star_file)

    pause(2)
    close all
end
