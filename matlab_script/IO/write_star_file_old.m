function write_star_file(header_file, data, output)
% WRITE_STAR_FILE
%   write_star_file(header_file, data, output)
% @author HB
% @date 28/09/2007
% @lastmod 20071212

fid = fopen(output, 'wt');

if exist(header_file, 'file')
    fid_header = fopen(header_file, 'rt');

    while (1)
        tline = fgetl(fid_header);
        if ~ischar(tline)
            break;
        end
        if regexp(tline, '^\s*[0-9]+\s+[0-9]+')
            break
        end
        fprintf(fid, '%s\n', tline);
        if regexp(tline, '_micrograph\.box_radius_x')
            param = regexp(tline, '\s+', 'split');
            box_radius_x = str2double(param{2});          
        end
        if regexp(tline, '_micrograph\.box_radius_y')
            param = regexp(tline, '\s+', 'split');
            box_radius_y = str2double(param{2});
        end
        if regexp(tline, '_micrograph\.box_radius_z')
            param = regexp(tline, '\s+', 'split');
            box_radius_z = str2double(param{2});
        end        
    end

    fclose(fid_header);
end


for i = 1:size(data, 1);
    fprintf(fid, '%2d %5.4f %7.2f %7.2f %7.2f %6.2f %6.2f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %1d\n', ...
        i, 1, data(i,1), data(i,2), data(i,3), box_radius_x, box_radius_y, box_radius_z, 0, 0, 1, 0, 1, 1);
end

fprintf(fid, '\n');
fclose(fid);