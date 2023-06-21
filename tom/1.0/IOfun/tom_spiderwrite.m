function tom_spiderwrite(filename,Data)
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

% Modified: 17/01/2007
% Unable to write stack file

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
    Data = tom_spiderheader(Data);
end

try
    fid = fopen(filename,'wb');
catch
    error(['Could not open' filename]);
end

%number of slices in volume (size of volume in z direction)
fwrite(fid,Data.Header.Spider.nslice,'float32');

%number of rows per slice (size of volume in x direction)
fwrite(fid,Data.Header.Spider.nrow,'float32');

%total number of records in the file (unused)
fwrite(fid,Data.Header.Spider.irec,'float32');

%(obsolete, unused)
fwrite(fid,Data.Header.Spider.nhistrec,'float32');

%file type specifier. Obsolete file types d, 8, 11, 12, 16, -1, -3, -7, and -9 are no longer supported in SPIDER.
%iform  	(type)  	data type
%1 	(r) 	2D image.
%3 	(r) 	3D volume.
%-11 	(fo) 	2D Fourier, mixed radix odd.
%-12 	(fe) 	2D Fourier, mixed radix even.
%-21 	(fo) 	3D Fourier, mixed radix odd.
%-22 	(fe) 	3D Fourier, mixed radix even.
fwrite(fid,Data.Header.Spider.iform,'float32');

%imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
%standard deviation have been computed and stored into this header record (see following locations).
fwrite(fid,Data.Header.Spider.imami,'float32');

%maximum value
fwrite(fid,Data.Header.Spider.fmax,'float32');

%minimum value
fwrite(fid,Data.Header.Spider.fmin,'float32');

%average value
fwrite(fid,Data.Header.Spider.av,'float32');

%standard deviation. A value of -1.0 indicates that sig has not been computed previously.
fwrite(fid,Data.Header.Spider.sig,'float32');

%(obsolete, no longer used).
fwrite(fid,Data.Header.Spider.ihist,'float32');

%number of pixels per line. (size of volume in y direction)
fwrite(fid,Data.Header.Spider.nsam,'float32');

%number of records in file header (label).
fwrite(fid,Data.Header.Spider.labrec,'float32');

%flag that tilt angles are present.
fwrite(fid,Data.Header.Spider.iangle,'float32');

%tilt angle
%The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between 
%different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside 
%labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
fwrite(fid,Data.Header.Spider.phi,'float32');

%tilt angle
fwrite(fid,Data.Header.Spider.theta,'float32');

%tilt angle (also called psi).
fwrite(fid,Data.Header.Spider.gamma,'float32');

%x translation
fwrite(fid,Data.Header.Spider.xoff,'float32');

%y translation
fwrite(fid,Data.Header.Spider.yoff,'float32');

%z translation
fwrite(fid,Data.Header.Spider.zoff,'float32');

%scale factor
fwrite(fid,Data.Header.Spider.scale,'float32');

%total number of bytes in header.
fwrite(fid,Data.Header.Spider.labbyt,'float32');

%record length in bytes.
fwrite(fid,Data.Header.Spider.lenbyt,'float32');

%This position has a value of 0 in simple 2D or 3D (non-stack) files. 
%In an "image stack" there is one overall stack header followed by a stack of images in 
%which each image has its own image header. (An image stack differs from a simple 3D image 
%in that each stacked image has its own header.) A value of >0 in this position in the overall 
%stack header indicates a stack of images. A value of <0 in this position in the overall stack 
%header indicates an indexed stack of images and gives the maximum image number allowed in the index.
fwrite(fid,Data.Header.Spider.istack,'float32');

%Unused
fwrite(fid,0,'float32');

%This position is only used in the overall header for a stacked image file. There, this position contains 
%the number of the highest image currently used in the stack. This number is updated, if necessary, when an 
%image is added or deleted from the stack.
fwrite(fid,Data.Header.Spider.maxim,'float32');

%This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
fwrite(fid,Data.Header.Spider.imgnum,'float32');

%This position is only used in the overall header of indexed stacks. There,
%this position is the highest index currently in use.
fwrite(fid,Data.Header.Spider.lastindx,'float32');

%next 2 words are unused
fwrite(fid,0,'float32');
fwrite(fid,0,'float32');

%flag that additional angles are present in header. 1 = one additional
%rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
fwrite(fid,Data.Header.Spider.Kangle,'float32');

%phi1
fwrite(fid,Data.Header.Spider.phi1,'float32');

%theta1
fwrite(fid,Data.Header.Spider.theta1,'float32');

%psi1
fwrite(fid,Data.Header.Spider.psi1,'float32');

%phi2
fwrite(fid,Data.Header.Spider.phi2,'float32');

%theta2
fwrite(fid,Data.Header.Spider.theta2,'float32');

%psi2
fwrite(fid,Data.Header.Spider.psi2,'float32');

fwrite(fid,zeros(174,1),'float32');

%create in date e.g. 27-MAY-1999
cdat = upper(date);
fwrite(fid, cdat,'char');
fwrite(fid, 0,'char');

%creation time e.g. 09:43:19
ctim = datestr(now,13);
fwrite(fid, ctim,'char');

%title
fwrite(fid, Data.Header.Spider.ctit,'char');

%finished writing header, see if the position for the values is correct.
fillup = Data.Header.Spider.labbyt-ftell(fid);

if fillup > 0
    fwrite(fid,0,'char',fillup-1);
end

%write the values
%reshape data
nsam = Data.Header.Spider.nsam;
nrow = Data.Header.Spider.nrow;
nslice = Data.Header.Spider.nslice;

if (Data.Header.Spider.iform > 0)
    % reshape data
    data = zeros(1, nsam*nrow*nslice);
    for i = 1:nslice
        page = Data.Value(:,:,i)';
        data((i-1)*nsam*nrow+1:i*nsam*nrow) = reshape(page, 1, nsam*nrow);
    end

else
    data_real = real(Data.Value);
    data_imag = imag(Data.Value);
    data2_real = zeros(1, nrow*nslice*nsam/2);
    data2_imag = zeros(1, nrow*nslice*nsam/2);

    for i = 1 : nslice
        page_r = data_real(:,:,i)';
        page_i = data_imag(:,:,i)';
        istart = (i-1)*nrow*nsam/2 + 1;
        iend = i*nrow*nsam/2;
        data2_real(istart:iend) = reshape(page_r, 1, nrow*nsam/2);
        data2_imag(istart:iend) = reshape(page_i, 1, nrow*nsam/2);
    end

    data = zeros(1, nrow*nslice*nsam);
    data(1:2:nrow*nslice*nsam) = data2_real;
    data(2:2:nrow*nslice*nsam) = data2_imag;
end

fwrite(fid,Data.Value,'float32');

fclose(fid);
