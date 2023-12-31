function [average, av_ps] = av3_average(motivelist, filename, r, flag, class)
% AV3_AVERAGE  performs averaging of 3D-particles from tomogram
%
% USAGE
%   [average av_ps] = av3_average(motivelist, filename, r, flag, class);
%
% PARAMETERS
%  INPUT
%   MOTIVELIST    motivelist (motl); for format see AV3_COLLECTPARTICLES 
%   FILENAME      string; filename of tomogram 
%                      -> files have to be EM-format
%   R             Radius of particles
%   FLAG          - 'var'    normalize volumes to variance before averaging
%                 - 'normal' not normalized
%
%  OUTPUT
%   AVERAGE       averaged particle
%   AV_PS         mask of power-spectrum -> ifftn(av_ps) can be used as
%                 point-spread function
%
%SEE ALSO
%   AV3_COLLECTPARTICLES
%
%   FF 09/24/02 
% last change 03/31/05 FF - changed docu
eps = 300;   % use as parameter for creating mask out of ps
error(nargchk(3,5,nargin));
if (nargin < 5) 
    class = 0;
end;
if (nargin < 4)
    flag = 'normal';
end;
npart=size(motivelist,2);
ipart = 0;
vol = tom_emread(filename);
for i=1:npart,
    if (nargin < 4) | (motivelist(20,i) == class )
        i
        ifile = motivelist(4,i); %corresponding filenumber
        %file=strcat(filename, '_', num2str(ifile), '.em');
        x=motivelist(8,i);y=motivelist(9,i);z=motivelist(10,i);
        part = tom_red(vol.Value,[x-r y-r z-r], [2*r+1 2*r+1 2*r+1]);
        phi = motivelist(17,i); psi = motivelist(18,i); theta=motivelist(19,i);
        %add translation later! to be done!
        part = double(tom_rotate(part, [-psi, -phi, -theta]));
        % normalize if flag is set
        if (nargin > 2)
            if strmatch(flag,'var')
                [dummy dummy dummy rms ] = tom_dev(part);
                part = part/rms;
            end;
        end;
        % average
        if i == 1
            average = part*0; %initialize
            av_ps = average;
        end;
        average = part + average;
        % calculate pointspread function in fourier space
        ps = tom_ps(part);
        ind = find(ps > eps);nind = find(ps <= eps);
        ps(ind) = 1; ps(nind)=0;   %    binary ps
        av_ps = av_ps + ps; % 
        ipart = ipart + 1; % number of particles averaged
    end;
end;
disp(['  ' num2str(ipart) '  particles averaged '  ])
file=strcat(filename, '_average.em');
tom_emwrite(file, average);
file=strcat(filename, '_average_fpointspread.em');
tom_emwrite(file, av_ps);
%convolute with average
faverage = fftshift(fftn(average));faverage = faverage.*av_ps; 
%average = ifftn(ifftshift(faverage));
%file=strcat(filename, '_filtered_average.em');
%tom_emwrite(file, average);
