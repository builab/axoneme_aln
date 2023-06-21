%-------------------------------------------------------------------------------
% Script: auto_pick_mtb_2d_script
% @purpose read x3d coordinate file, picking with specified periodicity & write new file
% @date 20091118
%-------------------------------------------------------------------------------

list_file = 'list.txt';


list = parse_simple_list(list_file);

for i = 1 : length(list)
    % Input
    input_file = list{i};
    disp(input_file)

	auto_pick_mtb_2d_24nm_script
	 
end



