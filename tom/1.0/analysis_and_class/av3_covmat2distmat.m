function distmat = av3_covmat2distmat(covmat)
%   distmat = av3_covmat2distmat(covmat)
%
%   converts covariance matrix to dist matrix.
%
%   INPUT
%   covmat      covariance matrix (symmetric!)
%
%   OUTPUT
%   distmat     distance matrix (lower triangle)
%
%   FF 03/06/05
icount = 1;
for ii=1:size(covmat,1)-1
    for jj=ii+1:size(covmat,2)
        distmat(icount) = covmat(ii,jj);
        icount = icount + 1;
    end;
end;