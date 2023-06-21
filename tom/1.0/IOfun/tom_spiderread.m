function Data = tom_spiderread(filename, select)
%TOM_SPIDERREAD reads in a SPIDER file
%
%   Data = tom_spiderread(filename)
%	 select is the image number in a stacked image file (start at 0)
%
%PARAMETERS
%  INPUT
%   filename
%
%  OUTPUT
%   data		...
%
%
%SEE ALSO
%   TOM_SPIDERWRITE, TOM_SPIDERHEADER, TOM_ISSPIDERFILE
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

% Modified: 05/07/2007
% Can't read all images in the stack into our structure


if nargin <1 
    [filename, pathname] = uigetfile({'*.spi';'*.*'}, 'Pick a spider file');
    if isequal(filename,0) || isequal(pathname,0); disp('No data loaded.'); return; end;
    filename=[pathname filename];
end;

if nargin < 2
	select = 0;
end

try
    fid = fopen(filename,'rb');
catch
    error(['Could not open' filename]);
end

Data = struct();
Data.Header = struct();
Data.Header.Spider = struct();

do_swap = 0;
SWAPTRIG = 655356;
SPIDERSIZE = 1024; % minimum header size

%number of slices in volume (size of volume in z direction)
nslice = fread(fid,1,'float=>float32');

%number of rows per slice (size of volume in x direction)
nrow = fread(fid,1,'float=>float32');

%total number of records in the file (unused)
irec = fread(fid,1,'float=>float32');

%(obsolete, unused)
nhistrec = fread(fid,1,'float=>float32');

%file type specifier. Obsolete file types d, 8, 11, 12, 16, -1, -3, -7, and -9 are no longer supported in SPIDER.
%iform  	(type)  	data type
%1 	(r) 	2D image.
%3 	(r) 	3D volume.
%-11 	(fo) 	2D Fourier, mixed radix odd.
%-12 	(fe) 	2D Fourier, mixed radix even.
%-21 	(fo) 	3D Fourier, mixed radix odd.
%-22 	(fe) 	3D Fourier, mixed radix even.
iform = fread(fid,1,'float=>float32');

% Checking for byte swapping
if (abs(nslice) > SWAPTRIG) || (abs(nslice) < 1) || (abs(iform) > SWAPTRIG)
	do_swap = 1;
end

if (do_swap == 1) 
	Data.Header.Spider.nslice = double(swapbytes(nslice));
	Data.Header.Spider.nrow = double(swapbytes(nrow));
	Data.Header.Spider.irec = double(swapbytes(irec));
	Data.Header.Spider.nhistrec = double(swapbytes(nhistrec));
	Data.Header.Spider.iform= double(swapbytes(iform));
	
	% Continue to swap other words in header

	%imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
	%standard deviation have been computed and stored into this header record (see following locations).
	Data.Header.Spider.imami = double(swapbytes(fread(fid,1,'float=>float32')));

	%maximum value
	Data.Header.Spider.fmax = double(swapbytes(fread(fid,1,'float=>float32')));

	%minimum value
	Data.Header.Spider.fmin = double(swapbytes(fread(fid,1,'float=>float32')));

	%average value
	Data.Header.Spider.av = double(swapbytes(fread(fid,1,'float=>float32')));

	%standard deviation. A value of -1.0 indicates that sig has not been computed previously.
	Data.Header.Spider.sig = double(swapbytes(fread(fid,1,'float=>float32')));

	%(obsolete, no longer used).
	Data.Header.Spider.ihist = double(swapbytes(fread(fid,1,'float=>float32')));

	%number of pixels per line. (size of volume in y direction)
	Data.Header.Spider.nsam = double(swapbytes(fread(fid,1,'float=>float32')));

	%number of records in file header (label).
	Data.Header.Spider.labrec = double(swapbytes(fread(fid,1,'float=>float32')));

	%flag that tilt angles are present.
	Data.Header.Spider.iangle = double(swapbytes(fread(fid,1,'float=>float32')));

	%tilt angle
	%The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between 
	%different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside 
	%labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
	Data.Header.Spider.phi = double(swapbytes(fread(fid,1,'float=>float32')));

	%tilt angle
	Data.Header.Spider.theta = double(swapbytes(fread(fid,1,'float=>float32')));

	%tilt angle (also called psi).
	Data.Header.Spider.gamma = double(swapbytes(fread(fid,1,'float=>float32')));

	%x translation
	Data.Header.Spider.xoff = double(swapbytes(fread(fid,1,'float=>float32')));

	%y translation
	Data.Header.Spider.yoff = double(swapbytes(fread(fid,1,'float=>float32')));

	%z translation
	Data.Header.Spider.zoff = double(swapbytes(fread(fid,1,'float=>float32')));

	%scale factor
	Data.Header.Spider.scale = double(swapbytes(fread(fid,1,'float=>float32')));

	%total number of bytes in header.
	Data.Header.Spider.labbyt = double(swapbytes(fread(fid,1,'float=>float32')));

	%record length in bytes.
	Data.Header.Spider.lenbyt = double(swapbytes(fread(fid,1,'float=>float32')));

	%%This position has a value of 0 in simple 2D or 3D (non-stack) files. 
	%In an "image stack" there is one overall stack header followed by a stack of images in 
	%which each image has its own image header. (An image stack differs from a simple 3D image 
	%in that each stacked image has its own header.) A value of >0 in this position in the overall 
	%stack header indicates a stack of images. A value of <0 in this position in the overall stack 
	%header indicates an indexed stack of images and gives the maximum image number allowed in the index.
	Data.Header.Spider.istack = double(swapbytes(fread(fid,1,'float=>float32')));

   fread(fid, 1, 'float');
    
	%This position is only used in the overall header for a stacked image file. There, this position contains 
	%the number of the highest image currently used in the stack. This number is updated, if necessary, when an 
	%image is added or deleted from the stack.
	Data.Header.Spider.maxim = double(swapbytes(fread(fid,1,'float=>float32')));

	%This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
	Data.Header.Spider.imgnum = double(swapbytes(fread(fid,1,'float=>float32')));

	%This position is only used in the overall header of indexed stacks. There, this position is the highest index currently in use.
	Data.Header.Spider.lastindx = double(swapbytes(fread(fid,1,'float=>float32')));

	%next 2 words are unused
	Data.Header.Spider.dummy1 = double(swapbytes(fread(fid,1,'float=>float32')));
	Data.Header.Spider.dummy2 = double(swapbytes(fread(fid,1,'float=>float32')));

	%flag that additional angles are present in header. 1 = one additional rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
	Data.Header.Spider.Kangle = double(swapbytes(fread(fid,1,'float=>float32')));

	%phi1
	Data.Header.Spider.phi1 = double(swapbytes(fread(fid,1,'float=>float32')));

	%theta1
	Data.Header.Spider.theta1 = double(swapbytes(fread(fid,1,'float=>float32')));

	%psi1
	Data.Header.Spider.psi1 = double(swapbytes(fread(fid,1,'float=>float32')));

	%phi2
	Data.Header.Spider.phi2 = double(swapbytes(fread(fid,1,'float=>float32')));

	%theta2
	Data.Header.Spider.theta2 = double(swapbytes(fread(fid,1,'float=>float32')));

	%psi2
	Data.Header.Spider.psi2 = double(swapbytes(fread(fid,1,'float=>float32')));

else
	Data.Header.Spider.nslice = double(nslice);
	Data.Header.Spider.nrow = double(nrow);
	Data.Header.Spider.irec = double(irec);
	Data.Header.Spider.nhistrec = double(nhistrec);
	Data.Header.Spider.iform= double(iform);
	
	%imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
	%standard deviation have been computed and stored into this header record (see following locations).
	Data.Header.Spider.imami = fread(fid,1,'float');

	%maximum value
	Data.Header.Spider.fmax = fread(fid,1,'float');

	%minimum value
	Data.Header.Spider.fmin = fread(fid,1,'float');

	%average value
	Data.Header.Spider.av = fread(fid,1,'float');

	%standard deviation. A value of -1.0 indicates that sig has not been computed previously.
	Data.Header.Spider.sig = fread(fid,1,'float');

	%(obsolete, no longer used).
	Data.Header.Spider.ihist = fread(fid,1,'float');

	%number of pixels per line. (size of volume in y direction)
	Data.Header.Spider.nsam = fread(fid,1,'float');

	%number of records in file header (label).
	Data.Header.Spider.labrec = fread(fid,1,'float');

	%flag that tilt angles are present.
	Data.Header.Spider.iangle = fread(fid,1,'float');

	%tilt angle
	%The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between 
	%different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside 
	%labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
	Data.Header.Spider.phi = fread(fid,1,'float');

	%tilt angle
	Data.Header.Spider.theta = fread(fid,1,'float');

	%tilt angle (also called psi).
	Data.Header.Spider.gamma = fread(fid,1,'float');

	%x translation
	Data.Header.Spider.xoff = fread(fid,1,'float');

	%y translation
	Data.Header.Spider.yoff = fread(fid,1,'float');

	%z translation
	Data.Header.Spider.zoff = fread(fid,1,'float');

	%scale factor
	Data.Header.Spider.scale = fread(fid,1,'float');

	%total number of bytes in header.
	Data.Header.Spider.labbyt = fread(fid,1,'float');

	%record length in bytes.
	Data.Header.Spider.lenbyt = fread(fid,1,'float');

	%This position has a value of 0 in simple 2D or 3D (non-stack) files. 
	%In an "image stack" there is one overall stack header followed by a stack of images in 
	%which each image has its own image header. (An image stack differs from a simple 3D image 
	%in that each stacked image has its own header.) A value of >0 in this position in the overall 
	%stack header indicates a stack of images. A value of <0 in this position in the overall stack 
	%header indicates an indexed stack of images and gives the maximum image number allowed in the index.
	Data.Header.Spider.istack = fread(fid,1,'float');

   % OBSOLETE
	fread(fid, 1, 'float');
    
	%This position is only used in the overall header for a stacked image file. There, this position contains 
	%the number of the highest image currently used in the stack. This number is updated, if necessary, when an 
	%image is added or deleted from the stack.
	Data.Header.Spider.maxim = fread(fid,1,'float');

	%This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
	Data.Header.Spider.imgnum = fread(fid,1,'float');

	%This position is only used in the overall header of indexed stacks. There, this position is the highest index currently in use.
	Data.Header.Spider.lastindx = fread(fid,1,'float');

	%next 2 words are unused
	Data.Header.Spider.dummy1 = fread(fid,1,'float');
	Data.Header.Spider.dummy2 = fread(fid,1,'float');

	%flag that additional angles are present in header. 1 = one additional rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
	Data.Header.Spider.Kangle = fread(fid,1,'float');

	%phi1
	Data.Header.Spider.phi1 = fread(fid,1,'float');

	%theta1
	Data.Header.Spider.theta1 = fread(fid,1,'float');

	%psi1
	Data.Header.Spider.psi1 = fread(fid,1,'float');

	%phi2
	Data.Header.Spider.phi2 = fread(fid,1,'float');

	%theta2
	Data.Header.Spider.theta2 = fread(fid,1,'float');

	%psi2
	Data.Header.Spider.psi2 = fread(fid,1,'float');
end

% Char doesn't have to be swapped
% skip unused record (37-211)
fread(fid,174,'float');

%creation date e.g. 27-MAY-1999 
Data.Header.Spider.cdat = fread(fid,12,'*char')';

%creation time e.g. 09:43:19 
Data.Header.Spider.ctim = fread(fid,8,'*char')';

%title
Data.Header.Spider.ctit = fread(fid,160,'*char')';

%Didn't handle stacked images
if select < 0 || select >= Data.Header.Spider.maxim
	select = 0;
end

nsam = Data.Header.Spider.nsam;
nrow = Data.Header.Spider.nrow;
nslice = Data.Header.Spider.nslice;

element_size = 4; % size of float32
header_size = Data.Header.Spider.labbyt;
image_size = header_size + nsam*nrow*nslice*element_size;
page_size = nsam*nrow*nslice*element_size;

% Handling stack file
if (Data.Header.Spider.istack > 0) % Stacked file
    fseek(fid,header_size + select*image_size, 'bof');
    header = fread(fid, SPIDERSIZE, 'float=>float32');

    if header < 1
        error('No header for stacked image!!!')
        exit;
    end

    fseek(fid,header_size*2 + select*image_size, 'bof');
    data = fread(fid, page_size/element_size, 'float=>float32');

    if (do_swap)
        header = swapbytes(header);
        data = swapbytes(data);
    end

    Data.Header.Spider.xoff = header(17);
    Data.Header.Spider.yoff = header(18);
    Data.Header.Spider.zoff = header(19);
	
	 Data.Header.Spider.phi = header(14);
	 Data.Header.Spider.theta = header(15);
	 Data.Header.Spider.psi = header(16);

else

    fseek(fid, header_size, 'bof');

    data = fread(fid, page_size/element_size, 'float=>float32');

    if (do_swap)
        data = swapbytes(data);
    end

end

    % check if it is ft file
    if Data.Header.Spider.iform > 0
        data2 = zeros(1, nsam*nrow*nslice);
        for i = 1 : nslice
            page = reshape(data( (i-1)*nsam*nrow+1: nsam*nrow*i), nsam, nrow)';
            data2( (i-1)*nrow*nsam+1: i*nrow*nsam) = reshape(page, 1, nrow*nsam);
        end
        Data.Value = reshape(data2, nrow, nsam, nslice);
    else
        data_real = data(1:2:nsam*nrow*nslice); % to check
        data_imag = data(2:2:nsam*nrow*nslice); % to check
        data = complex(data_real, data_imag);
        data2 = zeros(1, nrow*nslice*nsam/2);
        for i = 1:nslice
            page = reshape(data((i-1)*nsam*nrow/2+1:nsam*nrow/2*i), nsam/2, nrow)';
            data2((i-1)*nrow*nsam/2+1:i*nrow*nsam/2) = reshape(page, 1, nrow*nsam/2);
        end
        Data.Value = reshape(data2, nrow, nsam/2, nslice);
    end

%construct general header
Data.Header.Size = [Data.Header.Spider.nrow; Data.Header.Spider.nsam; Data.Header.Spider.nslice];

fclose(fid);


