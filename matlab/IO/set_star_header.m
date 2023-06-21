function  bstar2 = set_star_header(bstar, parameter, value)
% SET_STAR_HEADER set bstar header item
% 		bstar2 = set_star_header(bstar, parameter, value)
% Parameters
%  IN
%		bstar a structure containing the star file content
%		parameter one of 23 parameters
%		value value to set
%  OUT
%		negative value if fail, new star if successful
%
% @author HB
% @date 20100615

for i = 1:size(bstar.HEADER, 2)
	if ~isempty(regexp(parameter, bstar.HEADER{i}{1}, 'match'))
		if isnumeric(value)
			value = num2str(value);
		end	
		bstar.HEADER{i}{2} = value;
		bstar2 = bstar;
		return;
	end
end

bstar2 = -1;

