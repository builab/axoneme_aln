function content = parse_spider_doc(spiderFile)
% PARSE_SPIDER_DOC to get content
%   content = parse_spider_doc(spiderFile)
% HB 20080206

content = [];

fid = fopen(spiderFile, 'rt');

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    data_line = regexp(tline, '\s*\d+', 'match');
    if ~isempty(data_line)
        content = [content ; str2num(tline)];
    end
end

fclose(fid);

content = content(:, 3:end);
