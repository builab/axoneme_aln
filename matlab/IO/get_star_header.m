function value = get_star_header(bstar, parameter)
% GET_STAR_HEADER get bstar header item
% 		value = get_star_header(bstar, parameter)
% Parameters
%  IN
%		bstar a structure containing the star file content
%		parameter one of 23 parameters
%  OUT
%		value value for that parameters
%
% @author HB
% @date 20100615

for i = 1:size(bstar.HEADER, 2)
	if ~isempty(regexp(parameter, bstar.HEADER{i}{1}, 'match'))
		value = bstar.HEADER{i}{2};
		break;
	end
end

