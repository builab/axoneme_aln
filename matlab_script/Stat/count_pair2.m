function c = count_pair2(seq)
% Count number of consecutive pair of a number in a sequence
% function c = count_pair(seq, num)
%	seq	seq of number N x 1 or 1 x N
%	num	number to count
%	c number of pair

seq2 = [seq(2:end) 0];
seq2 = seq2.*seq;

c = sum(seq2);
%for i = 1:length(seq)-1
%	if seq(i) == num && seq(i+1) == num
%		c = c + 1;
%	end
%end
