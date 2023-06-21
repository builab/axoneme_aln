function p = tom_spiderread2(filename, select)
%TOM_SPIDERREAD2 reads in a SPIDER file
%
%   Data = tom_spiderread2(filename, select)
%
%PARAMETERS
%
%  INPUT
%   filename
%   select no. of image in the stack
%  OUTPUT
%   data		...
%
%EXAMPLE
%
%REFERENCES
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

% Modified: 12/01/2007
% select = no. of image select from stack
% still have to fix time
% Work well with 3d & 2d non-stacked file
% Work well with 2d stack file
% 16/01/2007: Need to reshape row-wise instead of column wise: fixed
% Wrong text label
% 31/07/2007
% Read fourier transform & unpack to standard transform

if nargin < 2
    select = 0;
end

if nargin <1
    [filename, pathname] = uigetfile({'*.spi';'*.*'}, 'Pick a spider file');
    if isequal(filename,0) || isequal(pathname,0); disp('No data loaded.'); return; end;
    filename=[pathname filename];
end

try
    fid = fopen(filename,'rb');
catch
    error(['Could not open' filename]);
end

SPIDERSIZE = 1024;
do_swap = 0;
SWAPTRIG = 655356;


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
    nslice = double(swapbytes(nslice));
    nrow = double(swapbytes(nrow));
    irec = double(swapbytes(irec));
    nhistrec = double(swapbytes(nhistrec));
    iform= double(swapbytes(iform));

    % Continue to swap other words in header

    %imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
    %standard deviation have been computed and stored into this header record (see following locations).
    imami = double(swapbytes(fread(fid,1,'float=>float32')));

    %maximum value
    fmax = double(swapbytes(fread(fid,1,'float=>float32')));

    %minimum value
    fmin = double(swapbytes(fread(fid,1,'float=>float32')));

    %average value
    av = double(swapbytes(fread(fid,1,'float=>float32')));

    %standard deviation. A value of -1.0 indicates that sig has not been computed previously.
    sig = double(swapbytes(fread(fid,1,'float=>float32')));

    %(obsolete, no longer used).
    ihist = double(swapbytes(fread(fid,1,'float=>float32')));

    %number of pixels per line. (size of volume in y direction)
    nsam = double(swapbytes(fread(fid,1,'float=>float32')));

    %number of records in file header (label).
    labrec = double(swapbytes(fread(fid,1,'float=>float32')));

    %flag that tilt angles are present.
    iangle = double(swapbytes(fread(fid,1,'float=>float32')));

    %tilt angle
    %The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between
    %different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside
    %labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
    phi = double(swapbytes(fread(fid,1,'float=>float32')));

    %tilt angle
    theta = double(swapbytes(fread(fid,1,'float=>float32')));

    %tilt angle (also called psi).
    gamma = double(swapbytes(fread(fid,1,'float=>float32')));

    %x translation
    xoff = double(swapbytes(fread(fid,1,'float=>float32')));

    %y translation
    yoff = double(swapbytes(fread(fid,1,'float=>float32')));

    %z translation
    zoff = double(swapbytes(fread(fid,1,'float=>float32')));

    %scale factor
    scale = double(swapbytes(fread(fid,1,'float=>float32')));

    %total number of bytes in header.
    labbyt = double(swapbytes(fread(fid,1,'float=>float32')));

    %record length in bytes.
    lenbyt = double(swapbytes(fread(fid,1,'float=>float32')));

    %%This position has a value of 0 in simple 2D or 3D (non-stack) files.
    %In an "image stack" there is one overall stack header followed by a stack of images in
    %which each image has its own image header. (An image stack differs from a simple 3D image
    %in that each stacked image has its own header.) A value of >0 in this position in the overall
    %stack header indicates a stack of images. A value of <0 in this position in the overall stack
    %header indicates an indexed stack of images and gives the maximum image number allowed in the index.
    istack = double(swapbytes(fread(fid,1,'float=>float32')));

    fread(fid,1,'float');

    %This position is only used in the overall header for a stacked image file. There, this position contains
    %the number of the highest image currently used in the stack. This number is updated, if necessary, when an
    %image is added or deleted from the stack.
    maxim = double(swapbytes(fread(fid,1,'float=>float32')));

    %This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
    imgnum = double(swapbytes(fread(fid,1,'float=>float32')));

    %This position is only used in the overall header of indexed stacks. There, this position is the highest index currently in use.
    lastindx = double(swapbytes(fread(fid,1,'float=>float32')));

    %next 2 words are unused
    fread(fid,2,'float');

    %flag that additional angles are present in header. 1 = one additional rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
    Kangle = double(swapbytes(fread(fid,1,'float=>float32')));

    %phi1
    phi1 = double(swapbytes(fread(fid,1,'float=>float32')));

    %theta1
    theta1 = double(swapbytes(fread(fid,1,'float=>float32')));

    %psi1
    psi1 = double(swapbytes(fread(fid,1,'float=>float32')));

    %phi2
    phi2 = double(swapbytes(fread(fid,1,'float=>float32')));

    %theta2
    theta2 = double(swapbytes(fread(fid,1,'float=>float32')));

    %psi2
    psi2 = double(swapbytes(fread(fid,1,'float=>float32')));

else
    nslice = double(nslice);
    nrow = double(nrow);
    irec = double(irec);
    nhistrec = double(nhistrec);
    iform= double(iform);

    %imami = maximum/minimum flag. Is set at 0 when the file is created, and at 1 when the maximum, minimum, average, and
    %standard deviation have been computed and stored into this header record (see following locations).
    imami = fread(fid,1,'float');

    %maximum value
    fmax = fread(fid,1,'float');

    %minimum value
    fmin = fread(fid,1,'float');

    %average value
    av = fread(fid,1,'float');

    %standard deviation. A value of -1.0 indicates that sig has not been computed previously.
    sig = fread(fid,1,'float');

    %(obsolete, no longer used).
    ihist = fread(fid,1,'float');

    %number of pixels per line. (size of volume in y direction)
    nsam = fread(fid,1,'float');

    %number of records in file header (label).
    headrec = fread(fid,1,'float');

    %flag that tilt angles are present.
    iangle = fread(fid,1,'float');

    %tilt angle
    %The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between
    %different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside
    %labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
    phi = fread(fid,1,'float');

    %tilt angle
    theta = fread(fid,1,'float');

    %tilt angle (also called psi).
    gamma = fread(fid,1,'float');

    %x translation
    xoff = fread(fid,1,'float');

    %y translation
    yoff = fread(fid,1,'float');

    %z translation
    zoff = fread(fid,1,'float');

    %scale factor
    scale = fread(fid,1,'float');

    %total number of bytes in header.
    labbyt = fread(fid,1,'float');

    %record length in bytes.
    lenbyt = fread(fid,1,'float');

    %This position has a value of 0 in simple 2D or 3D (non-stack) files.
    %In an "image stack" there is one overall stack header followed by a stack of images in
    %which each image has its own image header. (An image stack differs from a simple 3D image
    %in that each stacked image has its own header.) A value of >0 in this position in the overall
    %stack header indicates a stack of images. A value of <0 in this position in the overall stack
    %header indicates an indexed stack of images and gives the maximum image number allowed in the index.
    istack = fread(fid,1,'float');

    %Inused
    fread(fid,1,'float');

    %This position is only used in the overall header for a stacked image file. There, this position contains
    %the number of the highest image currently used in the stack. This number is updated, if necessary, when an
    %image is added or deleted from the stack.
    maxim = fread(fid,1,'float');

    %This position is only used in a stacked image header. There, this position contains the number of the current image or zero if the image is unused.
    imgnum = fread(fid,1,'float');

    %This position is only used in the overall header of indexed stacks. There, this position is the highest index currently in use.
    lastindx = fread(fid,1,'float');

    %next 2 words are unused
    fread(fid,2,'float');

    %flag that additional angles are present in header. 1 = one additional rotation is present, 2 = additional rotation that preceeds the rotation that was stored in words 15..20.
    Kangle = fread(fid,1,'float');

    %phi1
    phi1 = fread(fid,1,'float');

    %theta1
    theta1 = fread(fid,1,'float');

    %psi1
    psi1 = fread(fid,1,'float');

    %phi2
    phi2 = fread(fid,1,'float');

    %theta2
    theta2 = fread(fid,1,'float');

    %psi2
    psi2 = fread(fid,1,'float');
end


% Char doesn't have to be swapped
% skip unused record (37-211)
fread(fid,174,'float');

%creation date e.g. 27-MAY-1999
cdat = fread(fid,12,'*char');

%creation time e.g. 09:43:19
ctim = fread(fid,8,'*char');

%title
ctit = fread(fid,160,'*char');

% put into structure & initialize
p.px = 0;
p.py = 0;
p.pz = 0;
p.x = uint32(nsam);
p.y = uint32(nrow);
p.z = uint32(nslice);

p.c = 1;
p.n = 1; % to check
p.colormodel = 'gray';
p.datatype = 'float32';
p.transform = 'notr'; % No transform

if (iform < 0)
    p.transform = 'std';
    p.datatype = 'complexfloat';
    if (mod(iform,2) == 0)
        p.mixrad = 0; % even
    else
        p.mixrad = 1; % odd
    end
end

p.offset = uint32(labbyt);
p.min = fmin;
p.max = fmax;
p.avg = av;
p.std = sig;
p.ux = scale;
p.uy = scale;
p.uz = scale;

try
    [p.hour p.minute p.sec] = strread(ctim','%d%d%d','delimiter',':');
catch
    this_time = datevec(datestr(now,13));
    p.hour = this_time(4);
    p.minute = this_time(5);
    p.sec = this_time(6);
end

try
    [p.day p.month p.year] = strread(cdat','%d%s%d','delimiter','-');
catch
    [p.year p.month p.day] = strread(upper(date),'%d%s%d','delimiter','-');
end

if p.year > 100
    p.year = p.year - 2000;
end

p.label = ctit;

% read data info
element_size = 4;
header_size = p.offset;
image_size = double(header_size) + double(p.x*p.y*p.z)*element_size;
page_size = double(p.x*p.y*p.z*element_size);

%Reserved for stacked images
%imstart = 0;
%imend = maxim;

if (select > -1) % if an image is choosen from the stack
    if (select > p.n)
        select = 0;
    end
%    imstart = select;
%    imend = select+1;
%    p.n = 1;
%    p.i = select;
end

p.image.ox = xoff;
p.image.oy = yoff;
p.image.oz = zoff;

% Convert euler angle to view
view = view_from_euler(phi,theta,gamma);
p.image.vx = view.x;
p.image.vy = view.y;
p.image.vz = view.z;
p.image.angle = view.a;

% reset select to get the correct offset
if (select < 0)
    select = 0;
end

% reading header & image data of stack file
if (istack > 0)
    fseek(fid,header_size + select*image_size, 'bof');
    header = fread(fid, SPIDERSIZE, 'float=>float32');

    if header < 1
        error('No header for stacked image!!!')
    end

    fseek(fid,header_size*2 + select*image_size, 'bof');
    data = fread(fid, page_size/element_size, 'float=>float32');

    if (do_swap)
        header = swapbytes(header);
        data = swapbytes(data);
    end

    p.image.ox = header(17);
    p.image.oy = header(18);
    p.image.oz = header(19);

    view = view_from_euler(header(16),header(15),header(14));
    p.image.vx = view.x;
    p.image.vy = view.y;
    p.image.vz = view.z;

else
    fseek(fid, header_size, 'bof');

    data = fread(fid, page_size/element_size, 'float=>float32');

    if (do_swap)
        data = swapbytes(data);
    end
end


    if iform < 0 % FT file
        if p.mixrad == 0 % odd x dimension
            p.x = p.x - 2;
        else
            p.x = p.x - 1;
        end
        
        data_real = data(1:2:nsam*nrow*nslice); % to check
        data_imag = data(2:2:nsam*nrow*nslice); % to check
        data = complex(data_real, data_imag);
        data2 = zeros(1, nrow*nslice*nsam/2);
        for i = 1:nslice
            page = reshape(data((i-1)*nsam*nrow/2+1:nsam*nrow/2*i), nsam/2, nrow)';
            data2((i-1)*nrow*nsam/2+1:i*nrow*nsam/2) = reshape(page, 1, nrow*nsam/2);
        end
        data = reshape(data2, nrow, nsam/2, nslice);
        data = herm_to_std(data, p.mixrad);
    else
        data2 = zeros(1, nsam*nrow*nslice);
        for i = 1:nslice
            page = reshape(data((i-1)*nsam*nrow+1:nsam*nrow*i), nsam, nrow)';
            data2((i-1)*nrow*nsam+1:i*nrow*nsam) = reshape(page, 1, nrow*nsam);
        end
        data = reshape(data2, nrow, nsam, nslice);
    end

    % save data
    p.data = data;

% there are more complicated case but not for SPIDER
fclose(fid);


