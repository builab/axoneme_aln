function content = parse_simple_list(listFile)
% PARSE_SIMPLE_LIST parse simple list file containing file names
%	content = parse_simple_list(listFile)
% Parameters
% 	IN
%   listFile input list file
%  OUT
%   content is the cell array containing items in the list

fid = fopen(listFile, 'rt');
if fid == -1
    error('Cannot open list file');
end

i = 1;

while (1)
    tline = fgetl(fid);
    if ~ischar(tline), break, end 		
    if strcmp(tline, ''), continue, end
    if ~isempty(regexp(tline, '^#', 'match')), continue, end
  
    content{i} = strtrim(tline);
    i = i+1;
end

fclose(fid);
