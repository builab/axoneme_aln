function pick_ind = bf_pick(len, start, period)
% BF_PICK backward & forward pick, specially  designed for IDA
%   pick_point = bf_pick(len, start, period)
% Parameters
%   len = vector cumulative lenght of the line
%   star start index to pick
% @author HB
% @date 20071018 TOBE fixed & tested

len_new = len - len(start);
last = length(len);

pick_ind = start;


% Forward loop
for i = 1:floor(len_new(last)/period)
	step = i*period;
    
	upper = find(len_new >= step);
    
    if ~isempty(upper)
        pick_ind = [pick_ind ; upper(1)];
    end
end

for i = 1:floor(abs(len_new(1))/period)
	step = -i*period;
	lower = find(len_new >= step);
    
    if ~isempty(lower)
        pick_ind = [lower(1) ; pick_ind];
    end
end
