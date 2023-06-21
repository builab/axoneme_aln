function p = calc_seq_prob2(seq, p1, p2)
% p = calc_seq_prob(seq, p1, p2)
% 	seq sequence to calculate
%	p1	probability of 1
%	p2	probablity of 2

p = 1;

for i = 1:length(seq)
	if seq(i) == 0
		p = p*p1;
	elseif seq(i) == 1
		p = p*p2;
	end
end
