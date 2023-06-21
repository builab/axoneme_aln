function av3_psialig(refilename, motlfilename, particlefilename, startindx,mask,hipass,lowpass,nfold,threshold,wedgelist,iclass, ibin, dispflag, limit)
% av3_psialig aligns 3D subtomograms to reference
%
%   av3_theta_alig (refilename, motlfilename, particlefilename, startindx, ...
%       mask,hipass,lowpass,nfold,threshold,wedgelist,iclass, ibin, dispflag, limit)
%   Filenames are expected as:
%       'filename'_#no.em
%
%   This procedures is desinged for the nutation alignment according to the
%   C2 symmetry axis for particles e.g. like GroEL/S or PAN.
%
%   In this routine, an alignment with respect to psi (in the 'EM'
%   convention the polar angle - in other software packages like 
%   'SPIDER' or 'EMAN' phi...) is performed. The alignment works as follows:
%   Each particle is aligned with the reference according to its
%   orientation and with an increment of psi of 180 deg. The two CCCs are
%   being compared and the better one eventually serves to reassign the
%   single particle orientation.
%
%  PARAMETERS
%   refilename          filename of reference(s) - 'refilename'_#no.em
%   motlfilename        filename of corresponding motl - 'motlfilename'_#no.em
%   particlefilename    filename of 3D-particles to be aligned and averaged
%                           'particlefilename'_#no.em
%   startindx           start index - Index of first reference AND motl
%   mask                mask - make sure dims are all right!
%   hipass              hipass - for X-corr
%   lowpass             lowpass - for X-corr
%   nfold               symmetry of particle (rotational symmetry along z 
%                           (e.g. 3 for 3-fold rotational symmetry)
%   threshold           Threshold*mean(ccc) is cutoff for averaging - e.g.
%                           choose 0.5 (mean of ccc from PREVIOUS iteration!)
%   wedgelist           array containing the tilt range - 1st column: no of
%                           tomogram, 2nd: minimum tilt, 3rd: max tilt
%   iclass              class of particles - default:0
%   ibin                binning - default 0
%   dispflag            flag for display - if set to 'nodisp' then no
%                       display, e.g. for batch mode - otherwise display.
%                       'Dspcub' views of average and X-correlation
%                       function are shown. - default: 'disp'
%   limit               optional : to limit the histogram of single particles
%                       and the reference, give as a factor of how many times
%                       std to cut, cut off intensities will be set to mean (lim 'z')
%                       default (omitted) : no normmalisation, no cutting
%
% Format of MOTL:
%    The following parameters are stored in the matrix MOTIVELIST of dimension (20, NPARTICLES):
%    column 
%       1         : Cross-Correlation Coefficient
%       2         : x-coordinate in full tomogram
%       3         : y-coordinate in full tomogram
%       4         : particle number
%       5         : running number of tomogram - used for wedgelist
%       6         : index of feature in tomogram (optional)
%       8         : x-coordinate in full tomogram
%       9         : y-coordinate in full tomogram
%       10        : z-coordinate in full tomogram
%       11        : x-shift in subvolume - AFTER rotation of template
%       12        : y-shift in subvolume - AFTER rotation of template
%       13        : z-shift in subvolume - AFTER rotation of template
%     ( 14        : x-shift in subvolume - BEFORE rotation of template )
%     ( 15        : y-shift in subvolume - BEFORE rotation of template )
%     ( 16        : z-shift in subvolume - BEFORE rotation of template )
%       17        : Phi (in deg)
%       18        : Psi
%       19        : Theta 
%       20        : class no
%
%  SEE ALSO
%   AV3_PHIALIG, AV3_SCAN_FAST
%
%   09/18/03 FF
% modified 03/21/05 FF - corrected bug in binning
%
% last change 14/11/05, should be almost 3x faster,
% adapted from Vince (don't waste time on masking),
% limit parameter introduced,
% bugfix in threshold calculation,
% tested KG & MB
%
% MB 20/04/06, based on av3_scan_fast

anzahl =0; % count reassigned particles
% start new masking stuff, 14/11/05
mask_template = ones( size(mask,1),size(mask,2),size(mask,3));
mask_lowpass_3 = tom_spheremask( mask_template, lowpass,3);
mask_hipass_2 = tom_spheremask( mask_template,hipass,2);
mask_x = mask_lowpass_3-mask_hipass_2;
clear mask_lowpass_3;
clear mask_hipass_2;
mask_y = tom_spheremask(mask_template,size(mask,1)/5,size(mask,1)/16);
% do some funny masking inline :
mcenter=[floor(size(mask,1)/2)+1, floor(size(mask,2)/2)+1, floor(size(mask,3)/2)+1];
[x,y,z]=ndgrid(0:size(mask,1)-1,0:size(mask,2)-1,0:size(mask,3)-1);
radius = floor((min(min(size(mask,1),size(mask,2)),size(mask,3))-1)/2) ;
x = sqrt((x+1-mcenter(1)).^2+(y+1-mcenter(2)).^2+(z+1-mcenter(3)).^2);
ind = find(x>=radius);
clear x y z mcenter;
mask_z = ones(size(mask,1), size(mask,2), size(mask,3));
mask_z(ind) = 0;
% end new masking stuff, 14/11/05
error(nargchk(10,14,nargin))
if nargin < 11 
    iclass = 0;
end;
if nargin < 12
    ibin = 0;
end;
if nargin < 13
    dispflag = 'disp';
end;
if ibin > 0
    mask = tom_bin(mask,ibin);
    mask_x = tom_bin(mask_x,ibin);mask_y = tom_bin(mask_y,ibin);mask_z = tom_bin(mask_z,ibin); % added 14/11/05, MB
    % account for binning in rotation center
    rcent = floor(size(mask)./2)-0.25;% so far only 'experimentally' checked for even dim
end;
npixels = sum(sum(sum(mask)));
cent= [floor(size(mask,1)/2)+1 floor(size(mask,2)/2)+1 floor(size(mask,3)/2)+1];
scf = size(mask,1)*size(mask,2)*size(mask,3);
ind = startindx;
name = [refilename '_' num2str(ind) '.em'];
ref = tom_emread(name);
if ibin > 0
    ref = tom_bin(ref.Value,ibin);
end;
if nargin < 12, 
    disp(['Starting Psi alignment ...']);
elseif nargin <= 13,
    disp(['Starting Psi alignment with binning of ' num2str(ibin) ' ... ']);
elseif nargin > 13,
    disp(['Starting Psi alignment with binning of ' num2str(ibin) ' and limit of ' num2str(limit) 'x rms']);
end;
    %wedge=tom_wedge(ref.Value,semiangle);
for ind = startindx:startindx
    name = [refilename '_' num2str(ind) '.em'];
    ref = tom_emread(name);
    disp(['read in file ' name]);
    ref = ref.Value;average=ref*0;
    wei = zeros(size(ref,1),size(ref,2),size(ref,3));%weighting function
    if ibin > 0
        ref = tom_bin(ref,ibin);
    end;
    ref = tom_symref(ref,nfold);
    [mref xx1 xx2 mstd] = tom_dev(ref,'noinfo');
    ref = (ref - mref)./mstd;
    %ref = tom_limit(ref,-limit,limit,'z'); % throw away the gold, TAKEN OUT MB 31/11/05
    [mref xx1 xx2 mstd] = tom_dev(ref,'noinfo');
    ref = (ref - mref)./mstd;
    %mask = tom_spheremask(ones(size(average,1),size(average,2),size(average,3)),roi,rsmooth);
    name = [motlfilename '_' num2str(ind) '.em'];
    motl = tom_emread(name);
    motl = motl.Value;
    if ibin > 0
        motl(11:16) = motl(11:16)/(2^ibin);%take binning into account
    end;
    indx = find ((motl(20,:) ==1 ) | (motl(20,:) == 2) | (motl(20,:) == iclass) ); meanv = mean(motl(1,indx));
    disp(['mean ccc of ' num2str(size(indx,2)) ' particles in classes 1, 2 and ' num2str(iclass) ' is: ' num2str(meanv)]);
    indx = find (motl(1,indx) > threshold*meanv);
    disp(['at given threshold of ' num2str(threshold) ', ' num2str(size(indx,2)) ' particles have a ccc larger than threshold*meanv: ' num2str(threshold*meanv)]);
    itomo_old = 0;
    for indpart = 1:size(motl,2)
        if ((motl(20,indpart) == 1) | (motl(20,indpart) == 2) | (motl(20,indpart) == iclass))
            itomo = motl(5,indpart);
            if itomo_old ~= itomo %wedge stuff - exact weighting according to list
                xx = find(wedgelist(1,:) == itomo);
                minangle= wedgelist(2,xx);
                maxangle= wedgelist(3,xx);
                wedge = av3_wedge(ref,minangle,maxangle);
                if (ibin > 0)
                    bigwedge = av3_wedge(average,minangle,maxangle);
                end;
                itomo_old = itomo;
            end;
            tshift = 0;
            phi_old=motl(17,indpart);
            psi_old=motl(18,indpart);
            the_old=motl(19,indpart);
            % read shift BEFORE rot
            xshift = motl(14,indpart);
            yshift = motl(15,indpart);
            zshift = motl(16,indpart);ccc = -1;
            ifile = motl(4,indpart);
            name = [particlefilename '_' num2str(ifile) '.em'];
            particle = tom_emread(name);particle = particle.Value;
            particle4av = particle;
            if ibin > 0
                particle = tom_bin(particle,ibin);
            end;
            if nargin > 13, % throw away the gold, modified 14/11/05, MB
                [pmean pmax pmin pstd] = tom_dev(particle,'noinfo');
                particle = (particle - pmean)./pstd;
                particle = tom_limit(particle,-limit,limit,'z'); 
            end; % end modify by MB
            % do not shift particle but mask !
            rshift(1) = motl(11,indpart);
            rshift(2) = motl(12,indpart);
            rshift(3) = motl(13,indpart);
            % create 180 degrees shift !!!!!! mod for theta alig !!!!!!
            [euler2 rshift2]=tom_sum_rotation([phi_old psi_old the_old; 0 180 0],[0 0 0; rshift]);
            if (ibin == 0)
                rmask = double(tom_rotate(mask,[phi_old,psi_old,the_old]));
            else
                rmask = double(tom_rotate(mask,[phi_old,psi_old,the_old],'linear',rcent));
            end;
            shiftmask = tom_shift(rmask,rshift);
            particle=shiftmask.*particle;
            particle= particle - shiftmask.*(sum(sum(sum(particle)))/npixels);%subtract mean in sphere
            fpart=fftshift(tom_fourier(particle));
            %apply bandpass
            fpart= ifftshift(fpart.*mask_x);
            %normalize
            fpart(1,1,1)=0;
            fpart = (size(fpart,1)*size(fpart,2)*size(fpart,3))*fpart/sqrt((sum(sum(sum(fpart.*conj(fpart))))));
            phi = phi_old; the = the_old; psi = psi_old;
            if (ibin == 0)
                 rpart=double(tom_rotate(ref,[phi,psi,the]));
                 rpart2=double(tom_rotate(ref,euler2));%! mod for theta !
            else
                 rpart=double(tom_rotate(ref,[phi,psi,the],'linear',rcent));
                 rpart2=double(tom_rotate(ref,euler2,'linear',rcent));%! mod for theta !
            end;
            if (ibin == 0)
                 rmask=double(tom_rotate(mask,[phi,psi,the]));
                 rmask2=double(tom_rotate(mask,euler2));
            else
                 rmask=double(tom_rotate(mask,[phi,psi,the],'linear',rcent));
                 rmask2=double(tom_rotate(mask,euler2,'linear',rcent));
            end;
            rpart = rpart.*rmask;%mask with smoothened edges
            rpart2 = rpart2.*rmask2;%! mod for theta !
            rpart = rpart - rmask.*(sum(sum(sum(rmask.*rpart)))/npixels); %subtract mean in mask
            rpart2 = rpart2 - rmask2.*(sum(sum(sum(rmask2.*rpart2)))/npixels);%! mod for theta !
            fref=fftshift(tom_fourier(rpart));
            fref2=fftshift(tom_fourier(rpart2));%! mod for theta !
            %apply bandpass
            fref=ifftshift(wedge.*fref.*mask_z.*mask_x);
            fref2=ifftshift(wedge.*fref2.*mask_z.*mask_x);%! mod for theta !
            fref(1,1,1)=0;
            fref2(1,1,1)=0;
            %calculate rms - IMPORTANT! - missing wedge!!!
            % changed back FF
            fref = (size(fref,1)*size(fref,2)*size(fref,3))*fref/sqrt((sum(sum(sum(fref.*conj(fref))))));% to be changed?
            fref2 = (size(fref2,1)*size(fref2,2)*size(fref2,3))*fref2/sqrt((sum(sum(sum(fref2.*conj(fref2))))));%! mod for theta !
            ccf = real(fftshift(tom_ifourier(fpart.*conj(fref)))).*mask_y;
            ccf2 = real(fftshift(tom_ifourier(fpart.*conj(fref2)))).*mask_y;%! mod for theta !
            ccf = ccf/(size(ccf,1).^3);% added for normalization - FF
            ccf2 = ccf2/(size(ccf2,1).^3);%! mod for theta !
            [pos ccc] = peak_det_2(real(ccf));
            [pos2 ccc2] = peak_det_2(real(ccf2));%! mod for theta !
            disp(['Particle no ' num2str(ifile) ' , Iteration no ' num2str(ind) ', ccc is ' num2str(ccc) ' & ccc2 is ' num2str(ccc2)]);
            if ccc2 > ccc
                  disp('reassigned ...')
                  anzahl = anzahl +1;
                  ccc = ccc2;
                  phi=euler2(1);
                  psi=euler2(2);
                  the=euler2(3);
                  pos = pos2;
                  ccf= ccf2;
                  rshift = rshift2;
            end
            tshift = pos-cent;
            if (strcmp(dispflag,'nodisp')~= 1 )
                  if (size(ccf)>100)
                       binf = int8(log2(size(ccf)/64));
                       tom_dspcub(tom_bin(ccf),binf(1));drawnow;
                  else
                       tom_dspcub(ccf);drawnow;
                  end;
            end;
            motl(17,indpart)=phi;
            motl(18,indpart)=psi;
            motl(19,indpart)=the;
            motl(11,indpart) = tshift(1)*(2^ibin);
            motl(12,indpart) = tshift(2)*(2^ibin);
            motl(13,indpart) = tshift(3)*(2^ibin);
            rshift = tom_pointrotate(tshift,-psi,-phi,-the);
            motl(14,indpart) = rshift(1)*(2^ibin);
            motl(15,indpart) = rshift(2)*(2^ibin);
            motl(16,indpart) = rshift(3)*(2^ibin);
            motl(1,indpart)=ccc;
            % take care: particle4av is NOT pre-shifted
            if (ccc > threshold*meanv) %kick off bad particles
                if (ibin == 0)
                    average = average + double(tom_rotate(tom_shift(particle4av,-tshift),[-psi,-phi,-the]));
                else
                    average = average + double(tom_rotate(tom_shift(particle4av,-tshift*(2^ibin)),[-psi,-phi,-the]));
                end;
                if (strcmp(dispflag,'nodisp')~= 1 )
                    if size(average,1)>100
                        tom_dspcub((tom_bin(average)));drawnow;
                    else
                        tom_dspcub((average));drawnow;
                    end;
                end;
                %weighting - avoid interpolation artefacts
                if (ibin ==0)
                    tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(wedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
                else
                    tmpwei = 2*tom_limit(tom_limit(double(tom_rotate(bigwedge,[-psi,-phi,-the])),0.5,1,'z'),0,0.5);
                end;
                wei = wei + tmpwei;
                motl(20,indpart)=1;%good particles -> class one
            else
                motl(20,indpart)=2;%bad CCF: kick into class 2
            end;
            %disp(['Particle no ' num2str(ifile) ' , Iteration no ' num2str(ind) ' ccc is ' num2str(ccc) ' & ccc2 is ' num2str(ccc2)]);
            if ( rem(indpart,10) == 0 )
                name = [motlfilename '_tmp_' num2str(ind+1) '.em'];
                tom_emwrite(name,motl);
            end;
        end; %endif 
    end;% end particle loop
    name = [motlfilename '_' num2str(ind+1) '.em'];
    tom_emwrite(name,motl);
    ixx = find (motl(20,:)==1);disp([ num2str(size(ixx,2)) ' particles are in class 1 after iteration No. ' num2str(ind)]);
    % do weighting
    lowp = floor(size(average,1)/2)-3;%lowpass
    wei = 1./wei;rind = find(wei > 100000);wei(rind) = 0;% take care for inf
    average = real(tom_ifourier(ifftshift(tom_spheremask(fftshift(tom_fourier(average)).*wei,lowp))));
    name = [refilename '_' num2str(ind+1) '.em'];
    tom_emwrite(name,average);
    disp(['wrote reference ' name]);
end; % end iteration loop
disp (['Number of reassigned particles :' num2str(anzahl)]);
