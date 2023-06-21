function [average average2 average3 average4 average5 average6 frc] = av3_resdet2(motl, particlefilename,wedgelist,num,nsym,threshold,mask)
% AV3_RESDET determines resolution of average
%
%   [average average2 average3 average4 average5 average6 frc] = av3_resdet2(motl, particlefilename,wedgelist,num,nsym,threshold,mask)
%
%   Procedure for resolution determination of particle reconstructed from
%   tomograms. Resolution determination has to be performed according to
%   the resulting Fourier-ring correlation FRC.
%
% PARAMETERS
%  INPUT
%   MOTL                Motive list
%   PARTICLEFILENAME    particlefilenames - individual tomograms are
%                       expected to be called <PARTICLEFILENAME>_no.em 
%   WEDGELIST           list of wedges
%   NUM                 Number of rings for FRC
%   NSYM                SYMMETRY
%   THRESHOLD           threshold for decrimination of particles according
%                       to CCC. 
%
%  OUTPUT
%   AVERAGE             average of 1st set of particles
%   AVERAGE2            average of 2nd set of particles
%   FRC                 Output stack of tom_frc
%   MASK                (optional, to mask before FRC)
%
%   11/03/03 FF
%   last change 27/01/05 FF
%
% modified by MB 06/06/05 :
% To make things smoother, three average pairs are created randomly.
% Supply MASK if desired (optional, will be multiplied with average before
% FRC). Set nsym to 1 if not desired (but this can help a lot).

indx = find (motl(1,:) > 0); meanv = mean(motl(1,indx));
indx = find (motl(1,:) > threshold*meanv);

% define average in advance
name = [particlefilename '_' num2str(motl(4,1)) '.em'];%last change
particle = tom_emread(name);particle = particle.Value;
wei = zeros(size(particle,1),size(particle,2),size(particle,3));
wei2 =wei;wei3 =wei;wei4 =wei;wei5 =wei;wei6 =wei;
average = wei;average3 = wei;average5 = wei;
average2 = wei;average4 = wei;average6 = wei;
if nargin<7, mask = ones(size(particle,1),size(particle,2),size(particle,3));end;

itomo_old = 0;
icount = 0;icount3 = 0;icount5 = 0;
icount2 = 0;icount4 = 0;icount6 = 0;
tag =1;%tag for splitting particles into 2 parts
vec = [round(rand) round(rand) round(rand)];
for indpart = 1:size(motl,2) 
    if (motl(1,indpart)>threshold*meanv ) & (motl(20,indpart)> 0)
        itomo = motl(5,indpart);
        xshift = motl(11,indpart);
        yshift = motl(12,indpart);
        zshift = motl(13,indpart);
        tshift = [xshift yshift zshift];
        phi=motl(17,indpart);
        psi=motl(18,indpart);
        the=motl(19,indpart);
        ifile = motl(4,indpart);
        name = [particlefilename '_' num2str(ifile) '.em'];
        particle = tom_emread(name);particle = particle.Value;
        particle = tom_limit(particle,-3,4,'z'); % throw away the gold
        if indpart == 1
            wei = zeros(size(particle,1),size(particle,2),size(particle,3));
            average = wei;
        end;
        if itomo_old ~= itomo %wedge stuff - exact weighting according to list
            xx = find(wedgelist(1,:) == itomo);
            minangle= wedgelist(2,xx);
            maxangle= wedgelist(3,xx);
            wedge = av3_wedge(particle,minangle,maxangle);
            itomo_old = itomo;
        end;
        if tag == 1
            ave = double(tom_rotate(tom_shift(particle,-tshift),[-psi,-phi,-the]));
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
            if vec(1) == 1,
                average = average + ave;wei = wei + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average1'  ]);icount = icount +1;
            else average2 = average2 + ave;wei2 = wei2 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average2'  ]);icount2 = icount2 +1;
            end;
            if vec(2) == 1,
                average3 = average3 + ave;wei3 = wei3 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average3'  ]);icount3 = icount3 +1;
            else average4 = average4 + ave;wei4 = wei4 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average4'  ]);icount4 = icount4 +1;
            end;
            if vec(3) == 1,
                average5 = average5 + ave;wei5 = wei5 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average5'  ]);icount5 = icount5 +1;
            else average6 = average6 + ave;wei6 = wei6 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average6'  ]);icount6 = icount6 +1;
            end;
            tag = 2;
        else
            ave2 = double(tom_rotate(tom_shift(particle,-tshift),[-psi,-phi,-the]));
            tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
            if vec(1) == 0,
                average = average + ave2;wei = wei + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average1'  ]);icount = icount +1;               
            else average2 = average2 + ave2;wei2 = wei2 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average2'  ]);icount2 = icount2 +1;                
            end;
            if vec(2) == 0,
                average3 = average3 + ave2;wei3 = wei3 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average3'  ]);icount3 = icount3 +1;                
            else average4 = average4 + ave2;wei4 = wei4 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average4'  ]);icount4 = icount4 +1;
            end;
            if vec(3) == 0,
                average5 = average5 + ave2;wei5 = wei5 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average5'  ]);icount5 = icount5 +1;                
            else average6 = average6 + ave2;wei6 = wei6 + tmpwei;
                disp(['Particle no ' num2str(ifile) ' added to average6'  ]);icount6 = icount6 +1;
            end;
            tag = 1; vec = [round(rand) round(rand) round(rand)];
        end;%if - even/odd
    end;%if - threshold
end;
lowp = floor(size(average,1)/2)-3;
wei = 1./wei;rind = find(wei > 100000);wei(rind) = 0;% take care for inf
average = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average)).*wei,lowp))));
wei2 = 1./wei2;rind = find(wei2 > 100000);wei2(rind) = 0;
average2 = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average2)).*wei2,lowp))));
wei3 = 1./wei3;rind = find(wei3 > 100000);wei3(rind) = 0;
average3 = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average3)).*wei3,lowp))));
wei4 = 1./wei4;rind = find(wei4 > 100000);wei4(rind) = 0;
average4 = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average4)).*wei4,lowp))));
wei5 = 1./wei5;rind = find(wei5 > 100000);wei5(rind) = 0;
average5 = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average5)).*wei5,lowp))));
wei6 = 1./wei6;rind = find(wei6 > 100000);wei6(rind) = 0;
average6 = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average6)).*wei6,lowp))));
disp('Averaging finished ...');
disp([num2str(icount) ' particles averaged to average1.' ]);
disp([num2str(icount2) ' particles averaged to average2.']);
disp([num2str(icount3) ' particles averaged to average3.']);
disp([num2str(icount4) ' particles averaged to average4.']);
disp([num2str(icount5) ' particles averaged to average5.']);
disp([num2str(icount6) ' particles averaged to average6.']);
average = mask.* tom_symref(average,nsym);
average2 = mask.* tom_symref(average2,nsym);
average3 = mask.* tom_symref(average3,nsym);
average4 = mask.* tom_symref(average4,nsym);
average5 = mask.* tom_symref(average5,nsym);
average6 = mask.* tom_symref(average6,nsym);
frc1 = tom_compare(average, average2, num);
frc2 = tom_compare(average3, average4, num);
frc3 = tom_compare(average5, average6, num);
frc = (double(frc1) + double(frc2) + double(frc3))/3;