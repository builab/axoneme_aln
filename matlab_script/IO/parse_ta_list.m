function content = parse_ta_list(taFile)
% PARSE_TA_LIST parse tilt angle list
%   content = parse_ta_list(taFile)
% HB 20080206
% 20080310 compatible with blank line

[fid, message] = fopen(taFile, 'rt');
if fid == -1
    msgbox('Cannot open tilt angle list file', 'Error');
    disp(message)
end

tline = 1;
i = 1;
content = cell(1,2);
while (tline > 0)
    tline = fgetl(fid);
    if (tline==-1)
        continue;
    end
		
    % Blank line
	if strcmp(tline, '')
		continue;
    end
    if ~isempty(strfind(tline, '#')) % check for comment line
        continue;
    end

    fla = regexp(tline, '^[\w\d]+', 'match');
    content{i,1} = fla{1};
    ang = regexp(tline, '\[(.*)\]', 'tokens');
    content{i,2} = str2num(ang{1}{1}); % Convert ang to array
    i = i+1;
end

fclose(fid);
