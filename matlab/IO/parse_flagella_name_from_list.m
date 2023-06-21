function flagList = parse_flagella_name_from_list(mtb_list)
% Parse_flagella_name_from_list get a cell structure of list name
%	flagList = parse_flagella_name_from_list(mtb_list)
% PARAMETERS
%	IN
%	 mtb_list output of parse_list function
%	OUT
%	 flagList list of flagella in the list in a cell structure {'fla1', 'fla2'}
% @HB
% @date 20101014

indx = 1;
for i = 1:numel(mtb_list{2})
    if i == 1
       flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
       flagList{indx} = flagName;
       indx = indx + 1;
       continue;
    end  
    if isempty(strfind(mtb_list{2}{i}, flagName))
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');        
        flagList{indx} = flagName;
        indx = indx + 1;
        continue;
    end
        
end