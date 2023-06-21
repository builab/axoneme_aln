function half = std_to_herm(ft)
% Convert standard fourier transform to a hermitian form
%		HALF = STD_TO_HERM(FT)
% ft: fourier transform
%
% @author HB
% @date 16/01/07
%
% Test: OK

nsam = size(ft, 2);
half = ft(:,1:floor(nsam/2)+1,:);


