function [mtb_list, number_of_records] = parse_list(fileName)
% Parse_list into a structure with N x 3
% 	[mtb_list, number_of_records] = parse_list(fileName)
% Parameters
% 	fileName list file
%	mtb_list mtb_list with cell{1,3}
%	number_of_records number of records in list
%
% HB 20080201
% 20080305 make compatible with comments #
% 20080402 make compatible with blank line

[fid, message] = fopen(fileName, 'rt');

if fid == -1
    error('Cannot open list file');
end

mtb_list = cell(1,3);
col_id = {};
col_star = {};
col_direct = [];
i = 1;
while 1
	tline = fgetl(fid);
	if ~ischar(tline), break, end
	if ~isempty(regexp(tline, '^#', 'match')), continue, end
	if strcmp(tline, ''), continue, end % Empty line

	data = textscan(tline, '%s %s %d');
	col_id{i} = data{1}{1};
	col_star{i} = data{2}{1};
	col_direct = [col_direct data{3}];
    i = i+1;
end

mtb_list{1} = col_id;
mtb_list{2} = col_star;
mtb_list{3} = col_direct;

fclose(fid);

number_of_records = numel(mtb_list{1});

