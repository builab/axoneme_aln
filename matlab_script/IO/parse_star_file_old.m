function content = parse_star_file(starFile, parameter)
% PARSE_STAR_FILE parse bsoft star file
% 	content = parse_star_file(starFile, parameter);
% Parameters
%	starFile star file to parse
%	parameter to retrieve
%		'origin'
% TODO improve to get more properties, or put the content in a structure
% HB 20080201
% 20080301 change completely, much faster & accurate
% 20080729 can deal with star file with X ray info now

content= [];

fid = fopen(starFile, 'rt');

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    data_line = regexp(tline, '^\s*\d+\s+([0-9\.])+', 'match');
	%disp(data_line)
    if ~isempty(data_line)       
        content = [content ; str2num(tline)];
    end
end

fclose(fid);

if nargin == 2
	switch parameter
		case 'origin'
			content = content(:,3:5);
		otherwise
	end
end



