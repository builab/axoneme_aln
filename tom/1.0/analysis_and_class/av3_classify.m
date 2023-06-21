function [motl, ccc, coeff] = av3_classify(motl, particlename, mask, ...
    wedgelist, threshold, neig, nclass, ibin)
% [motl, ccc, coeff] = av3_classify(motl, particlename, mask, wedgelist, threshold, neig, nclass)
% 
%   perform classification based on constrained correlation metric
%  INPUT
%   motl            motivelist
%   particlename    particlefilename    filename of 3D-particles to be aligned and averaged
%                   'particlefilename'_#no.em
%   mask            mask - make sure dims are all right!
%   wedgelist       array containing the tilt range - 1st column: no of
%                   tomogram, 2nd: minimum tilt, 3rd: max tilt
%   threshold       absolute Threshold
%   neig            number of eigenvectors used for PCA
%   nclass          number of classes for k-means clustering
%   ibin            binning
%
%   NOTE: The routine return the classified MOTL, the CCC matrix and the
%   coefficiens of the PCA. If you intend to classify using a different
%   number of eigenvectors or number of classes and have already calculated
%   the correlation matrix CCC, you should use that. The matrix is
%   independent of these parameters and it would be rather foolish to
%   calculate them afain. If you already have CCC just use the
%   classification commands from this routine:
%--------------------------------------------------------------------
%   [coeff, latent, explained] = pcacov(ccc);
%   for ii=1:neig
%     coeff(:,ii)=sqrt(abs(latent(ii)))*coeff(:,ii);
%   end;
%   % actual classification using k-means
%   T=kmeans(coeff(:,1:neig),nclass,'Start','cluster','Replicates',10,'MaxIter',1000);
%   motl(20,:)=T;
%----------------------------------------------------------------------
%
%   FF oct 2007

kk=find(motl(1,:)>threshold);% grep particles with highest SNR if desired
motl=motl(:,kk);
% here the correlation matrix is calculated
[ccc covar xc] = av3_cccmat(motl, particlename, wedgelist, mask,1,7,0, ibin, 'nodisp');
tom_emwrite('cccmat.em', ccc);% constrained correlation matrix - that's the one you should be interest in 
tom_emwrite('covarmat.em', covar);% covariance matrix - that's used by Reiner in the EM program
tom_emwrite('xcmat.em', xc);% correlation ~covariance matrix
[coeff, latent, explained] = pcacov(ccc);
for ii=1:neig
    coeff(:,ii)=sqrt(abs(latent(ii)))*coeff(:,ii);
end;
% eigenvectors - if you are interested in these
for ieig=1:neig
    average = av3_eigvec2vol(motl, coeff(:,ieig), particlename,wedgelist,0);%rec eigenvector
    tom_emwrite(['./ev_',num2str(ieig),'.em'], average);
end;
% actual classification using k-means
T=kmeans(coeff(:,1:neig),nclass,'Replicates',10,'MaxIter',1000);
motl(20,:)=T;
for ii=1:nclass
    [av, av_un] = av3_average_exact(motl, particlename,wedgelist,0.0,ii);
    tom_emwrite(['av_class_',num2str(ii),'.em'],av);
end;