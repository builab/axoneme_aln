function tom_spiderwrite2(filename, Data)
%TOM_SPIDERWRITE writes out a SPIDER file
%
%   tom_spiderwrite(filename, Data)
%
%PARAMETERS
%
%  INPUT
%   filename            ...
%   Data                ...
%
%  OUTPUT
%
%EXAMPLE
%   tom_amira_createisosurface(...);
%   creates ...
%
%REFERENCES
%
%SEE ALSO
%   TOM_SPIDERREAD, TOM_SPIDERHEADER, TOM_ISSPIDERFILE
%
%   created by AK 04/25/06
%
%   Nickell et al., 'TOM software toolbox: acquisition and analysis for electron tomography',
%   Journal of Structural Biology, 149 (2005), 227-234.
%
%   Copyright (c) 2004-2007
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute of Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom

% Modified: 16/01/2007
% Wrong label
% 16/01: Fix write transform file
% 16/11: Fix date problem
% Date incompatible with bsoft

if ~ischar(filename)
    error('First argument should be a string containing a valid file name.');
end

if nargin == 1
    error('Second argument should be a spider structure');
end

if nargin > 2
    error('This function takes only two arguments.');
end

if ~isstruct(Data)
    Data = tom_addheader(Data); % default no transform
end

try
    fid = fopen(filename,'wb');
catch
    error(['Could not open ' filename]);
end

%number of slices in volume (size of volume in z direction)
fwrite(fid,Data.z,'float32');

%number of rows per slice (size of volume in y direction)
fwrite(fid,Data.y,'float32');

%total number of records in the file (unused)
fwrite(fid,0,'float32');

%(obsolete, unused)
fwrite(fid,0,'float32');

%file type specifier. Obsolete file types d, 8, 11, 12, 16, -1, -3, -7, and -9 are no longer supported in SPIDER.
%iform  	(type)  	data type
%1 	(r) 	2D image.
%3 	(r) 	3D volume.
%-11 	(fo) 	2D Fourier, mixed radix odd.
%-12 	(fe) 	2D Fourier, mixed radix even.
%-21 	(fo) 	3D Fourier, mixed radix odd.
%-22 	(fe) 	3D Fourier, mixed radix even.
switch lower(Data.transform)
    case {'notr'}
        if (Data.z < 2)
            iform = 1; %2D
        else
            iform = 3; % 3D
        end
    case {'std'}
        if (Data.z < 2)
            iform = -12 + Data.mixrad; % 2D transform
        else
            iform = -22 + Data.mixrad; % 3D transform
        end
    otherwise
        disp('unknown transform type !')
end

fwrite(fid,iform,'float32');

%imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
%standard deviation have been computed and stored into this header record (see following locations).
fwrite(fid,0,'float32');

%maximum value
fwrite(fid,max(max(max(Data.data))),'float32');

%minimum value
fwrite(fid,min(min(min(Data.data))),'float32');


if (iform > 0)
    %average value
    avg = sum(sum(sum(Data.data)))/(Data.x*Data.y*Data.z);
    fwrite(fid, avg,'float32');

    %standard deviation. A value of -1.0 indicates that sig has not been computed previously.
    stddev = sum(sum(sum((Data.data - avg).^2)))/(Data.x*Data.y*Data.z -1);
    fwrite(fid,stddev,'float32');
else
    fwrite(fid, 0,'float32');
    fwrite(fid,-1,'float32');
end

%(obsolete, no longer used).
fwrite(fid,0,'float32');

if iform < 0
    nsam = Data.x + 2 - mod(Data.x, 2);
else
    nsam = Data.x;
end

%number of pixels per line. (size of volume in y direction)
fwrite(fid, nsam, 'float32');

labrec = ceil(256./nsam);
%number of records in file header (label).
fwrite(fid,labrec,'float32');

%flag that tilt angles are present.
fwrite(fid,0,'float32');

%tilt angle
%The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between
%different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside
%labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
[phi, theta, gamma] = euler_from_view(Data.image.vx, Data.image.vy, Data.image.vz, Data.image.angle);

fwrite(fid,phi,'float32');

%tilt angle
fwrite(fid,theta,'float32');

%tilt angle (also called psi).
fwrite(fid,gamma,'float32');

%x translation
fwrite(fid,Data.image.ox,'float32');

%y translation
fwrite(fid,Data.image.oy,'float32');

%z translation
fwrite(fid,Data.image.oz,'float32');

%scale factor
fwrite(fid,Data.ux,'float32');

%total number of bytes in header.
fwrite(fid,Data.offset,'float32');

%record length in bytes.
lenbyt = 4*nsam;
fwrite(fid,lenbyt,'float32');

%This position has a value of 0 in simple 2D or 3D (non-stack) files.
%In an "image stack" there is one overall stack header followed by a stack of images in
%which each image has its own image header. (An image stack differs from a simple 3D image
%in that each stacked image has its own header.) A value of >0 in this position in the overall
%stack header indicates a stack of images. A value of <0 in this position in the overall stack
%header indicates an indexed stack of images and gives the maximum image number allowed in the index.
fwrite(fid,0,'float32'); % unable to write stack file yet

%This position is only used in the overall header for a stacked image file. There, this position contains
%the number of the highest image currently used in the stack. This number is updated, if necessary, when an
%image is added or deleted from the stack.
fwrite(fid, 0, 'float32');

fwrite(fid,Data.n,'float32');

%This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
fwrite(fid,0,'float32');

%This position is only used in the overall header of indexed stacks. There,
%this position is the highest index currently in use.
fwrite(fid,0,'float32');

%next 2 words are unused
fwrite(fid,0,'float32');
fwrite(fid,0,'float32');

%flag that additional angles are present in header. 1 = one additional
%rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
%kangle + phi1 + theta1 + psi1 + phi2 + theta2 + psi2
fwrite(fid,zeros(7, 1),'float32');

fwrite(fid,zeros(174,1),'float32');

%create in date e.g. 27-MAY-1999
cdat = upper(date);
fwrite(fid, cdat, 'char');
fwrite(fid, 0, 'char');

%creation time e.g. 09:43:19
ctim = datestr(now,13);
fwrite(fid, ctim, 'char');

%title
fwrite(fid, Data.label,'char');

%finished writing header, see if the position for the values is correct.
fillup = Data.offset -ftell(fid);
if fillup > 0
    fwrite(fid,0,'char',fillup-1);
end

%write the values
if (iform > 0) % work good
    % reshape data
    data = zeros(1, Data.x*Data.y*Data.z);
    for i = 1:Data.z
        page = Data.data(:,:,i)';
        data((i-1)*Data.x*Data.y+1:i*Data.x*Data.y) = reshape(page, 1, Data.x*Data.y);
    end

else % fourier transform file
    data_herm = std_to_herm(Data.data);
    datasize = size(data_herm,1)*size(data_herm,2)*size(data_herm,3);
    data2 = zeros(1, datasize);
    for i = 1:size(data_herm,3)
        page = data_herm(:,:,i)';
        istart = (i-1)*size(data_herm,1)*size(data_herm,2) + 1;
        iend = i*size(data_herm,1)*size(data_herm,2);
        data2(istart:iend) = reshape(page, 1, size(data_herm,1)*size(data_herm,2));
    end
    data2_real = real(data2);
    data2_imag = imag(data2);
    data = zeros(1, datasize*2);
    data(1:2:datasize*2) = data2_real;
    data(2:2:datasize*2) = data2_imag;

end

fwrite(fid,data,'float32');

fclose(fid);

