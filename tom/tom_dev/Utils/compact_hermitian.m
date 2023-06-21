function half = compact_hermitian(ft)
%TOM_FT_TO_HERMITIAN
%
% Date: 16/01/07

nsam = size(ft, 2);

half = ft(:,1:floor(nsam/2)+1,:);


