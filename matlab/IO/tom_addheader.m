function p = tom_addheader(in, transformType, mixrad)
%TOM_ADDHEADER adds a header structure to a matrix
%
%   Data = tom_addheader(in, transformType, mixrad)
%
%	Build a  header structure and adds a
%   header to the in-Values with default values
%
%PARAMETERS
%
%  INPUT
%   in                  (Matrix or Volume)
%
%  OUTPUT
%   out                 Structure in  spider format with header and in.Value
%   out.Value           Raw data of in
%   out.Header          Header information with standard values
%
%EXAMPLE
%   tom_amira_createisosurface(...);
%   creates ...
%
%REFERENCES
%
%SEE ALSO
%   TOM_SPIDERWRITE, TOM_SPIDERREAD, TOM_ISSPIDERFILE
%   TransformType: 'herm', 'std', 'notr', 'cent', 'cher'
%
%   created by AK 04/26/06
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

%Date: 11/01/07


if isstruct(in)~=1
    %number of slices in volume (size of volume in z direction)
    p.z = size(in,3);

    %number of rows per slice (size of volume in x direction)
    p.y = size(in,1);


    %file type specifier. Obsolete file types d, 8, 11, 12, 16, -1, -3, -7, and -9 are no longer supported in SPIDER.
    %iform  	(type)  	data type
    %1 	(r) 	2D image.
    %3 	(r) 	3D volume.
    %-11 	(fo) 	2D Fourier, mixed radix odd.
    %-12 	(fe) 	2D Fourier, mixed radix even.
    %-21 	(fo) 	3D Fourier, mixed radix odd.
    %-22 	(fe) 	3D Fourier, mixed radix even.
    if nargin < 2
        transformType = 'notr'; % no transform
        mixrad = 0; % even
    end

    if nargin < 3
        mixrad = 0;
    end

    p.transform = transformType;

    if strcmp(transformType, 'herm') || strcmp(transformType,'cent_herm')
        p.datatype = 'complexfloat';
        p.mixrad = mixrad;
    elseif (strcmp(transformType, 'std'))
        p.datatype = 'complexfloat';
        p.transform = 'std';
        p.mixrad = mixrad;
    else
        p.transform = 'notr';
        p.datatype = 'float32';
        p.mixrad = mixrad;
    end

    %max value
    if p.z == 1
        p.max = max(max(in));
        p.min = min(min(in));
    else
        p.max = max(max(max(in)));
        p.min = min(min(min(in)));
    end

    %average value
    p.avg = 0;

    %standard deviation. A value of -1.0 indicates that sig has not been computed previously.
    p.std = -1.0;


    %number of pixels per line. (size of volume in x direction)
    p.x = size(in,2); % nsam

    p.colormodel = 'gray';
    %number of records in file header (label).
    labrec = ceil(256./p.x); %1024 ./ nsam .*4);

    % might have to change
    %if (mod(1024,p.x*4) ~= 0)
    %    labrec = labrec + 1;
    %end

    %tilt angle
    %The angle, offset & scale factor locations contained in the SPIDER header are available to communicate between
    %different SPIDER operations. Currently they are NOT used in the code distributed with SPIDER, but some outside
    %labs make extensive use of these positions. The angles are usually in Euler format and are given in degrees.
    view = view_from_euler(0,0,0);

    %tilt angle
    p.image.vx = view.x;
    p.image.vy = view.y;
    p.image.vz = view.z;
    p.image.angle = view.a;

    p.image.ox = 0;
    p.image.oy = 0;
    p.image.oz = 0;

    %scale factor
    p.ux = 0;
    p.uy = 0;
    p.uz = 0;


    %total number of bytes in header.
    p.offset = labrec*p.x*4;

    %This position has a value of 0 in simple 2D or 3D (non-stack) files.
    %In an "image stack" there is one overall stack header followed by a stack of images in
    %which each image has its own image header. (An image stack differs from a simple 3D image
    %in that each stacked image has its own header.) A value of >0 in this position in the overall
    %stack header indicates a stack of images. A value of <0 in this position in the overall stack
    %header indicates an indexed stack of images and gives the maximum image number allowed in the index.
    p.n = 1; %only non-stack files supported at the moment.
    p.i = 0;

    %creation date e.g. 27-MAY-1999
    this_time = datevec(datestr(now,13));
    p.hour = this_time(4);
    p.minute = this_time(5);
    p.sec = this_time(6);

    %creation time e.g. 09:43:19
    [p.year p.month p.day] = datevec(upper(date),'dd-mmm-yyyy');

    %title
    p.label = 'Created by Tombox Matlab';
    p.data = in;
else
    p = in;
    disp('This is already a structure!');
end;
