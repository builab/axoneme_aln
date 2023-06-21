function init = mfile_from_template(templateFile, data, mFileOut)
% MFILE_FROM_TEMPLATE
%   init = mfile_from_template(templateFile, data, mFileOut)
% Parameters
%   templateFile templateFile location
%   data cell array of data
%   mFileOut location of m file output
% HB 20080218 Tested
% @last_mod 20080408

fid_template = fopen(templateFile, 'rt');
fid = fopen(mFileOut, 'wt');

if (fid_template < 0)
    init = -1;
    return;
end

if fid < 0
    init = -1;
    return;
end

isNotHeader = 0;

indx = 1;
while (1)
        tline = fgetl(fid_template);
        if ~ischar(tline), break, end
        if ~isempty(strfind(tline, '%%% End header'))
            isNotHeader = 1;
            continue;
        end
        if ~isempty(regexp(tline, '^%', 'once')), continue, end
        if ~isNotHeader
            tline = [tline ' ' data{indx} ';'];
            indx = indx + 1;
        end
        fprintf(fid, '%s\n', tline);
end

fclose(fid);
fclose(fid_template);

init = 1;
