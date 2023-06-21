function [doublet_list, sub_mtb_list] = get_doublet_list(mtb_list, number_of_records, flagName)
% GET_DOUBLET_LIST get doublet list from a list
%   [doublet_list, sub_mtb_list] = get_doublet_list(mtb_list, number_of_records, flagName)
% PARAMETERS
%   IN
%    mtb_list	output of parse_list function
%    number_of_records	number of records in the list
%    flagName	flagellum name to extract
%   OUT
%    doublet_list list of the doublets in the flagellum (can be [1 .. 9] or partial)
%    sub_mtb_list same format as mtb_list but contains only the extracted flagellum
% HB 20080210
% 20090630 now work with both wt_van_01_ida_v1_1 or wt_van_01_1ida_v1
% 20110102 update to compatible with mtb_list

doublet_list = [];
sub_mtb_list = cell(1,3);

for i = 1:length(mtb_list{1})

    if ~isempty(strfind(mtb_list{2}{i}, flagName))  
        if ~isempty(regexp(mtb_list{2}{i}, 'ida_v\d$'))
            tmp = regexprep(mtb_list{2}{i}, 'ida_v\d$', '');    
            doublet_id = regexp(tmp, '\d$', 'match');
        else
            doublet_id = regexp(mtb_list{2}{i}, '\d$', 'match');
        end
    
        doublet_id = str2double(doublet_id);
        doublet_list = [doublet_list doublet_id];
        sub_mtb_list{1}{doublet_id} = mtb_list{1}{i};
        sub_mtb_list{2}{doublet_id} = mtb_list{2}{i};
        sub_mtb_list{3}(doublet_id) = mtb_list{3}(i);
    end

end
