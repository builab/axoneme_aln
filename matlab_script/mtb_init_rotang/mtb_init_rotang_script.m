% Script to calculate the initial rotation angle for mtb alignment
% TODO introduce sign to indicate which way the microtubule go by reversing
% the vector calculation in mtb_init_rotang function
% TODO introduce relative angle between doublet to limit psi

% HB 20080129

%%%% Demo %%%%%
points = load('curve_points.txt');

plot_pts(points, 'ro')
axis([1 2000 1 2000 1 400])
view(10,80)

rotang = mtb_init_rotang(points);


%%%% Utility %%%%%%
% Produce SPIDER document based on the rot angle
organism = 'chlamy';
star_file = 'mtb_init_rotang.star';
output = ['doc_init_' organism '_000.spi'];

% Extract points
unix(['cat ' star_file ' | grep ''^[[:space:]]*[0-9]''  > star.txt']);
star_content = load('star.txt');
points = star_content(:,3:5);

% Calculate initial transform
rotang = mtb_init_rotang(points);
transform = zeros(size(points,1), 6);
transform(:,1:3) = rotang;
write_spider_doc(transform, output);

%%%% Utility %%%%%%
% Mass produce SPIDER document based on the estimated rot angle, psi from
% doc_macm
list = 1:61;

for loop_ind = list
    fid = fopen('list_chlamy.txt', 'rt');
    c = textscan(fid, '%s %s');
    fclose(fid);

    star_path = '../chlamy/star';
    doc_path = '../chlamy/doc';

    star_file = [star_path '/' c{2}{loop_ind} 'm.star'];
    doc_mac_file = [doc_path '/doc_macm_' c{1}{loop_ind} '.spi'];
    output_doc_init = [doc_path '/doc_init_' c{1}{loop_ind} '.spi'];
    
    disp(c{1}{loop_ind})
    disp(star_file)
    disp(doc_mac_file)

    period = 240;
    limit_factor = 3;
    pixel_size = 6.8571;

    % Load file & Fitting
    unix(['cat ' star_file ' | grep ''^[[:space:]]*[0-9]''  > star.txt']);
    unix(['cat ' doc_mac_file ' | grep ''^[[:space:]]*[0-9]''  > aln.txt']);

    % Read aln_file
    star_content = load('star.txt');
    points = star_content(:,3:5);

    fid = fopen(doc_mac_file, 'rt');
    while (1)
        tline = fgetl(fid);
        if findstr(tline, ';')
            continue;
        end
        doc_content = sscanf(tline, '%d %d %f %f %f %f %f %f');
        euler = doc_content(3:5)';
        break;
    end
    fclose(fid);
    
    disp(['Euler: ' num2str(euler)])
    if (euler(1) > 0 && euler(1) < 180) 
        rotang = mtb_init_rotang(points, 0);
    else
        rotang = mtb_init_rotang(points, 1);
    end
    transform = zeros(size(points,1), 6);
    transform(:,1:3) = rotang;
    transform(:,3) = euler(3)*ones(size(points,1),1);
    write_spider_doc(transform, output_doc_init);
    


end