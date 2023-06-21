function pick_ind = ida_bf_pick(len_ang, start, period, variant_no)
% BF_PICK backward & forward pick, specially  designed for IDA
%   pick_point = ida_bf_pick(len_ang, start, period, variant_no)
%
% @author HB
% @date 20071018 fixed & tested
len_ang_new = len_ang - len_ang(start);
last = length(len_ang);

pick_ind = cell(1,variant_no);
pick_ind{1} = start;

variant_ind = 1;

% Forward loop
for i = 1:floor(len_ang_new(last)*variant_no/period)
    %disp(variant_ind)
    variant_ind = rem(variant_ind+1, variant_no);
    if (variant_ind == 0) 
        variant_ind = variant_no;
    end
    
	step = i*period/variant_no;
    
	upper = find(len_ang_new >= step);
    
    if ~isempty(upper)
        pick_ind{variant_ind} = [pick_ind{variant_ind} ; upper(1)];
    end
end

variant_ind = 1;

for i = 1:floor(abs(len_ang_new(1))*variant_no/period)
    %disp(variant_ind)
    variant_ind = rem(variant_ind-1, variant_no);
    if (variant_ind == 0) 
        variant_ind = variant_no;
    end
    
	step = -i*period/variant_no;
	lower = find(len_ang_new >= step);
    
    if ~isempty(lower)
        %disp(lower(1))
        pick_ind{variant_ind} = [lower(1) ; pick_ind{variant_ind}];
    end
end
