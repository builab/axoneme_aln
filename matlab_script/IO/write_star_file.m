function write_star_file(varargin)
% WRITE_STAR_FILE write star file format
% Usage 1
%   write_star_file(headerFile, origins, outputFile)
% PARAMETERS
%   headerFile the file to get the header from
%   origins origins of the particles Nx3 array
%   outputFile output file name
% Usage 2
%   write_star_file(bstar, outputFile)
%   bstar the bstar structure
%
% @author HB
% @date 28/09/2007
% @lastmod 20071212
% @lastmod 20100614 write compatible with 1.6

if nargin < 2
    error 'Not enough arguments'
end
if nargin == 2
    write_bstar(varargin{1}, varargin{2});
    return;
end

if nargin == 3
    headerFile = varargin{1};
    origins = varargin{2};
    outputFile = varargin{3};
end
    
if exist(headerFile, 'file')
    bstar = parse_star_file(headerFile);
else
    error 'Cannot open file';
end

nopart = size(origins, 1);
data = zeros(nopart, 16);
data(:,5:7) = origins;
data(:,1) = transpose(1:nopart);
data(:,2) = ones(nopart, 1);
data(:,4) = ones(nopart, 1);
data(:,8) = ones(nopart, 1) * str2double(get_star_header(bstar, '_particle.box_radius_x'));
data(:,9) = ones(nopart, 1) * str2double(get_star_header(bstar, '_particle.box_radius_y'));
data(:,10) = ones(nopart, 1) * str2double(get_star_header(bstar, '_particle.box_radius_z'));
data(:,13) = ones(nopart, 1);
data(:,15) = ones(nopart, 1);
data(:,16) = ones(nopart, 1);

bstar.DATA = data;

write_bstar(bstar, outputFile);

function write_bstar(bstar, outputFile)
% WRITE_BSTAR write a bstar structure into file

fid = fopen(outputFile, 'wt');
fprintf(fid, '#Writen by Matlab function write_star_file.m %s\n\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'));
fprintf(fid, 'data_%s\n\n', bstar.NAME);

for i = 1:size(bstar.HEADER, 2)
    fprintf(fid, '%-40s%s\n', bstar.HEADER{i}{1}, bstar.HEADER{i}{2});
end

fprintf(fid, '\n');

fprintf(fid, 'loop_\n');
for i = 1:size(bstar.PARTICLEHEADER, 2)
    fprintf(fid, '%s\n', bstar.PARTICLEHEADER{i});
end
for i = 1:size(bstar.DATA, 1)
    fprintf(fid, '%4d %5d %5d %5.4f %7.2f %7.2f %7.2f %6.3f %6.3f %6.3f %6.4f %6.4f %6.4f %6.2f %6.4f %2d\n', bstar.DATA(i,:));
end
fprintf(fid, '\n');

if ~isempty(bstar.DATA_BAD)
    fprintf(fid, 'loop_\n_particle.bad_x\n_particle.bad_y\n_particle.bad_z\n');
    for i = 1: size(bstar.DATA_BAD, 1)
        fprintf(fid, '%.2f %.2f %.2f\n', bstar.DATA_BAD(i,:));
    end
    fprintf(fid, '\n');
end
fclose(fid);



