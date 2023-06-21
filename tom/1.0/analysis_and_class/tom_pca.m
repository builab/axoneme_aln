function [ccc, conorm] = tom_pca(motl, particlefilename, wedgelist,mask,hipass,lowpass,iclass,ibin)
% TOM_PCA computes correlation- and conormalization matrix of particles
%
%   [ccc conorm] = tom_pca(motl, particlefilename,
%   wedgelist,mask,hipass,lowpass,iclass,ibin)
%
% PARAMETERS
%  INPUT
%   motl                MOTive List
%   particlefilename    filename of 3D-particles to be aligned and averaged
%                           'particlefilename'_#no.em
%   wedgelist           array containing the tilt range - 1st: no of
%                           tomogram, 2nd: minimum tilt, 3rd: max tilt
%   mask                mask - make sure dims are all right!
%   hipass              hipass - for X-corr
%   lowpass             lowpass - for X-corr
%   iclass              class of particles - fixed to 1 or 2
%   ibin                binning - default 0
%
%  OUTPUT
%   ccc                 constrained cross correlation matrix
%   conorm               constrained conormiance matrix
%
%   The cross correlation coefficient is calculated in real space, thus the
%   translation is NOT determined. The CCC that is calculated here is
%   constrained in the following sense: For computing the correlation of
%   any pair of particles, the data is constrained to the part of Fourier
%   space that is sampled by both data. This can be achieved by
%   multiplying a mask in Fourier space. This normalization is only done
%   when FLAG is set to 'norm'. If FLAG is 'unchanged', then the
%   CCC is computed without normalizing the particles to the standard
%   deviation. The default is 'norm' where normalization is performed.
%
%   As an additional property the conormiance matrix is computed. 
%   For subsequent evaluation the eigenvalues and vectors should be
%   computed using EIG of EIGS.
%
% EXAMPLE
%
% SEE ALSO
%   TOM_CORR, TOM_ORCD
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
%
%   last change
%   04/08/04 FF

if nargin < 8
    ibin = 0;
end;
if ibin>0
    mask = tom_bin(mask,ibin);
    % account for binning in rotation center
    rcent = floor(size(mask)./2)-0.25;% so far only 'experimentally' checked for even dim
end;

if nargin < 7 
    iclass = 0;
end;
icount = 0;
itomo_old = 0;
npixels = sum(sum(sum(mask)));
for indpart1 = 1:size(motl,2) 
    ifile1 = motl(4,indpart1);
    if ( (motl(20,indpart1) == iclass) | (motl(20,indpart1) == 1) | (motl(20,indpart1) == 2) )
        icount = icount +1;
        itomo = motl(5,indpart1);
        xshift = motl(11,indpart1);
        yshift = motl(12,indpart1);
        zshift = motl(13,indpart1);
        tshift = [xshift yshift zshift]/(2^ibin);
        phi = motl(17,indpart1);
        psi = motl(18,indpart1);
        the = motl(19,indpart1);
        name = [particlefilename '_' num2str(ifile1) '.em'];
        particle = tom_emread(name);
        if ibin > 0
            particle = tom_bin(particle.Value,ibin);
        else
            particle = particle.Value;
        end;
        %if icount == 1
        %    wei = zeros(size(particle,1),size(particle,2),size(particle,3));
        %    average = wei;
        %end;
        if itomo_old ~= itomo %wedge stuff - exact weighting according to list
            xx = find(wedgelist(1,:) == itomo);
            minangle= wedgelist(2,xx);
            maxangle= wedgelist(3,xx);
            wedge = av3_wedge(particle,minangle,maxangle);
            itomo_old = itomo;
        end;
        if (ibin == 0)
            rpart1 = double(tom_rotate(tom_shift(particle,-tshift),[-psi,-phi,-the]));
        else
            rpart1 = double(tom_rotate(tom_shift(particle,-tshift),[-psi,-phi,-the],'linear',rcent));
        end;
        frpart1 = fftshift(tom_fourier(rpart1));
        frpart1 = tom_spheremask(frpart1,lowpass,3) - tom_spheremask(frpart1,hipass,2);
        tmpwei1 = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
        %wei = wei + tmpwei;
        itomo_old2=0;
        icount2=0;
        for indpart2 =indpart1:size(motl,2)
            if ((motl(20,indpart2) == iclass) | (motl(20,indpart2) == 1) | (motl(20,indpart2) == 2))
                icount2 = icount2 +1;
                itomo2 = motl(5,indpart2);
                xshift = motl(11,indpart2);
                yshift = motl(12,indpart2);
                zshift = motl(13,indpart2);
                tshift = [xshift yshift zshift]/(2^ibin);
                phi = motl(17,indpart2);
                psi = motl(18,indpart2);
                the = motl(19,indpart2);
                ifile2 = motl(4,indpart2);
                name = [particlefilename '_' num2str(ifile2) '.em'];
                particle2 = tom_emread(name);
                if ibin > 0
                    particle2 = tom_bin(particle2.Value,ibin);
                else
                    particle2 = particle2.Value;
                end;
                %if icount2 == 1
                %    wei = zeros(size(particle2,1),size(particle2,2),size(particle2,3));
                %    average = wei;
                %end;
                if itomo_old2 ~= itomo2 %wedge stuff - exact weighting according to list
                    xx = find(wedgelist(1,:) == itomo2);
                    minangle2= wedgelist(2,xx);
                    maxangle2= wedgelist(3,xx);
                    wedge2 = av3_wedge(particle2,minangle2,maxangle2);
                    itomo_old2 = itomo2;
                end;
                if (ibin == 0)
                    rpart2 = double(tom_rotate(tom_shift(particle2,-tshift),[-psi,-phi,-the]));
                else
                    rpart2 = double(tom_rotate(tom_shift(particle2,-tshift),[-psi,-phi,-the],'linear',rcent));
                end;
                tmpwei2 = 2*tom_limit(tom_limit(double(tom_rotate(wedge2,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
                tmpwei = tmpwei1.*tmpwei2;
                wpix = sum(sum(sum(tmpwei)));
                cpart1 = frpart1.*tmpwei;
                cpart1 = real(tom_ifourier(ifftshift(cpart1)));
                cpart2 = fftshift(tom_fourier(rpart2)).*tmpwei;
                cpart2 = tom_spheremask(cpart2,lowpass,3) - tom_spheremask(cpart2,hipass,2);
                cpart2 = real(tom_ifourier(ifftshift(cpart2)));
                cpart1 = cpart1.*mask;mn1 = (sum(sum(sum(cpart1))))/npixels;
                cpart1 = cpart1 - mask.*mn1;
                stv1 = sqrt(sum(sum(sum(cpart1.*cpart1))));
                cpart1 = cpart1/stv1;
                cpart2 = cpart2.*mask;mn2 = (sum(sum(sum(cpart2))))/npixels;
                cpart2 = cpart2 - mask.*mn2;
                stv2 = sqrt(sum(sum(sum(cpart2.*cpart2))));
                conorm(indpart1,indpart2) = 1/stv1 * 1/stv2;
                conorm(indpart2,indpart1) = conorm(indpart1,indpart2);
                cpart2 = cpart2/stv2;
                ccc(indpart1,indpart2) = sum(sum(sum(cpart1.*cpart2)));
                ccc(indpart2,indpart1) = ccc(indpart1,indpart2);
                imagesc(ccc);colorbar;drawnow;
            else
                ccc(indpart1,indpart2) = 0;
                ccc(indpart2,indpart1) = ccc(indpart1,indpart2);%bugfix 4.08.04 FF
            end;
        end;%if - class
    end;
    %ccc(indpart1,indpart1) = 1;
    disp(['Correlation and covariance computed for particle no ' num2str(ifile1) ' ...']);
end;
%ccc = ccc+eye(size(motl,2));
