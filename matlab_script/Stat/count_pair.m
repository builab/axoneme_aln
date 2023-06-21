function c = count_pair(seq, num)
% Count number of consecutive pair of a number in a sequence
% function c = count_pair(seq, num)
%	seq	seq of number N x 1 or 1 x N
%	num	number to count
%	c number of pair

c = 0;
for i = 1:length(seq)-1
	if seq(i) == num && seq(i+1) == num
		c = c + 1;
	end
end
