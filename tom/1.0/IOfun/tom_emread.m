function [Data] = tom_emread(em_name,form,nr,area)

% TOM_EMREAD reads data in EM-file format
%
%    Reads an EM-Image File (V-Format) 
%	 a raw format with a 512 Byte Header.
%    If no header was provided in EMWRITE
%    the header information will be
%    abandoned in EMREAD.
%    That way data can be saved 
%    and loaded without providing a header
%    but with compatible file-format to EM.
%    The keyword 'subregion' followed by a 3D vector 
%    and a subregion 3D vector reads only a subregion
%    from a 3D volume. Only supported for floats and int16
%    in 3D.
%    
%
%    Structure of EM-Data Files:
%    -Byte 1: Machine Coding:       Machine:    Value:
%                                   OS-9         0
%                                   VAX          1
%                                   Convex       2
%                                   SGI          3
%                                   Sun          4 (not supported)
%                                   Mac          5
%                                   PC           6
%    -Byte 2: General purpose. On OS-9 system: 0 old version 1 is new version
%    -Byte 3: Not used in standard EM-format, if this byte is 1 the header is abandoned. 
%    -Byte 4: Data Type Coding:         Image Type:     No. of Bytes:   Value:
%                                       byte            1               1
%                                       short           2               2
%                                       long int        4               4
%                                       float           4               5
%                                       complex         8               8
%                                       double          8               9
%    -Three long integers (3x4 bytes) are image size in x, y, z Dimension
%    -80 Characters as comment
%    -40 long integers (4 x 40 bytes) are user defined parameters
%    -256 Byte with userdata, first 20 chars username, 8 chars date (i.e.03/02/03)
%    -Raw data following with the x variable as the fastest dimension, then y and z
%
%    -The parameters are coded as follwing:
%       No.  |  Name  |  Value  |  Factor  |  Comment
%       1       U        Volt      1000       accelerating voltage
%       2       COE      mm        1000       Cs of objective lense
%       3       APE      mrad      1000       aperture
%       4       VE       x         1          end magnification
%       5       VN       1000      1000       postmagnification of CCD (fixed value:1000!)
%       6       ET       s         1000       exposure time in seconds
%       7       OBJ      nm        1000       pixelsize in object-plane
%       8       EM                 1          EM-Code:
%                                               EM420=1;CM12=2;CM200=3;
%                                               CM120/Biofilter=4;CM300=5;
%                                               Polara=6;extern=0;
%       9       CCD      �m        1000       physical pixelsize on CCD
%       10      L        �m        1000       phys_pixel_size * nr_of_pixels
%       11      DF       Angstr.   1          defocus, underfocus is neg.
%       12      FA       Angstr.   1          astigmatism
%       13      PHI      deg       1000       angle of astigmatism 
%       14      DDF      Angstr.   1          focusincr. for focus-series
%       15      CTS      -         1000       counts per primary electron, sensitivity of CCD
%       16      C2       -         1000       intensity value of C2
%       17      EW       eV        1          0 for no slit, x>0 for positive slitwidth 
%       18      EO       eV        1          energy offset from zero-loss
%       19      KW       deg       1000       tiltangle 
%       20      KR       deg       1000       tiltaxis
%       21      -        Angstr.   1           
%       22      SC       ASCII     1
%       23      -        -         -
%       24      -        pixel     1          markerposition X
%       25      -        pixel     1          markerposition Y
%       26      -        Angstr.   1000       internal: resolution
%       27      -        -         -          internal: density
%       28      -        -         -          internal: contrast
%       29      -        -         -          internal: unknown
%       30      SP       -         1000       mass centre X
%       31      SP       -         1000       mass centre Y
%       32      SP       -         1000       mass centre Z
%       33      H        -         1000       height
%       34      -        -         1000       internal: unknown
%       35      D1       -         1000       width 'Dreistrahlbereich'
%       36      D2       -         1000       width 'Achrom. Ring'
%       37      -        -         1          internal: lambda
%       38      -        -         1          internal: delta theta
%       39      -        -         1          internal: unknown
%       40      -        -         1          internal: unknown
%
%
%    Syntax:
%     [Data] = tom_emread(em_name)
%    Input:
%    em_name:       Filename
%    Output:
%     Data:     	Structure of Image Data
%     Data.Value:   Raw data of image, or stack
%     Data.Header:  Header information
%
%    Example:
%               i=tom_emread;
%                   a fileselect-box appears and the EM-file can be picked
%
%               i=tom_emread('Proj.em');
%
%               i=tom_emread('HPIEMV','subregion',[102 162 1],[23 29 0]);
%                   reads a subregion starting from position (102, 162,1) of an image
%                   and gives back an image of size (23,29). Alternative to read
%                   whole volume and reduce by
%                   redi=i.Value(102:124,162:190). 
%
%               i=tom_emread('TRIPODV','subregion',[14 17 19],[19 16 9]);
%                   reads a subregion starting from position (14,17,19) in the volume
%                   and gives back a volume of size (19,16,9). Alternative to read
%                   whole volume and reduce by redi=i.Value(14:33,17:33,19:28);
%
%    See Also
%     TOM_EMWRITE, TOM_EMHEADER, TOM_READEMHEADER
%
%    09/23/02 SN
%   last change 12/03/04 FF - bug fixed: fclose OUTSIDE 'if's
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


error(nargchk(0,4,nargin))
if nargin <1 
    form='standard';  nr=1;
    [filename, pathname] = uigetfile({'*.em;*.vol';'*.*'}, 'Pick an EM-file');
    if isequal(filename,0) | isequal(pathname,0) disp('No data loaded.'); return; end;
    em_name=[pathname filename];
end;

if nargin <3 form='standard';  nr=1; end;

% if nargin <1 error(['Filename not specified (e.g. emread(''c:\Data.em'')']);  end;

emtype=cellstr(['extern         '; 'EM420          '; 'CM12           '; 'CM200          '; 'CM120/Biofilter'; 'CM300          '; 'Polara         ']);
%                                               EM420=1;CM12=2;CM200=3;
%                                               CM120/Biofilter=4;CM300=5;
%                                               Polara=6;extern=0;
% open the stream with the correct format !
fid = fopen(em_name,'r','ieee-be');
if fid==-1
    error(['Cannot open: ' em_name ' file']); 
end;
magic = fread(fid,[4],'char');
fclose(fid);

% reads the header
%
% description in 'The Structure of the EM-Data Files', Herr Hegerl
% and at the bottom of this file

% read the Header 
%magic(1) = 3;

if (magic(1)==3 | magic(1)==0 | magic(1)==5)
    fid = fopen(em_name,'r','ieee-be'); % for SGI or OS-9 or Mac
else
    fid = fopen(em_name,'r','ieee-le'); % for PC
end;    
magic = fread(fid,[4],'char');
image_size = fread(fid,[3],'int32');
comment = char(fread(fid,[80],'char'));
parameter = fread(fid,[40],'int32');
fillup = char(fread(fid,[256],'char'));

% the size of the image
xdim = image_size(1);
ydim = image_size(2);
zdim = image_size(3);


if isequal(form,'standard')
    Data_read=zeros(xdim,ydim,zdim);
    if magic(4)==1
    	for lauf=1:zdim
    		Data_read(:,:,lauf) = fread(fid,[xdim,ydim],'char');
    	end;
    elseif magic(4)==2
    	for lauf=1:zdim
    		Data_read(:,:,lauf) = fread(fid,[xdim,ydim],'int16');
    	end;
    elseif magic(4)==4
    	for lauf=1:zdim
		    Data_read(:,:,lauf) = fread(fid,[xdim,ydim],'long');
	    end;
    elseif magic(4)==5
	    for lauf=1:zdim
    		Data_read(:,:,lauf) = fread(fid,[xdim,ydim],'float');
        end;
    elseif magic(4)==8
	    for lauf=1:zdim
		    waitbar(lauf./zdim);
		    Data_read(:,:,lauf) = fread(fid,[xdim,ydim],'float64');
	    end;
    else
        disp('Sorry, i cannot read this as an EM-File !!!');
        Data_read=[];
    end;
    
elseif isequal(form,'subregion')
    readsize_x=nr(1)+area(1);
    readsize_y=nr(2)+area(2);
    readsize_z=nr(3)+area(3);
    if readsize_x>xdim | readsize_y>ydim | readsize_z>zdim
%        error(['Subregion dimensions larger than volume dimensions.']);
        area_intended(1)=area(1);
        area_intended(2)=area(2);
        area_intended(3)=area(3);
        area(1)=xdim-nr(1);
        area(2)=ydim-nr(2);
        area(3)=zdim-nr(3);
    end;
    Data_read=zeros(area(1)+1,area(2)+1,area(3)+1);
    Data_read_xy=zeros(area(1)+1,area(2)+1);
    image_size(1)=area(1)+1;
    image_size(2)=area(2)+1;
    image_size(3)=area(3)+1;
    ilaufx=0;
    ilaufz=0;
    if magic(4)==1
    	for lauf=nr(3):area(3)+1
    		tmp = fread(fid,[nr(2):nr(2)+area(2),nr(1):nr(1)+area(1)],'char');
     		Data_read(:,:,lauf) = tmp(nr(2):(nr(2)+area(2)),nr(1):(nr(1)+area(1)));
   	    end;
    elseif magic(4)==2
        fseek_merker=0;
        fseek(fid,2*(nr(1)-1),0);
        fseek(fid,2*(xdim*(nr(2)-1)),0);
        fseek(fid,2*(ydim*xdim*(nr(3)-1)),0);
        for lauf=nr(3):nr(3)+area(3)
            for laufy=nr(2):(nr(2)+area(2))
                ilaufx=ilaufx+1;
    		    tmp = fread(fid,[area(1)+1],'int16');
                Data_read_xy(:,ilaufx)=tmp;
                fseek(fid,2*(xdim-area(1)-1),0);
                fseek_merker=fseek_merker+xdim;
            end;
            ilaufx=0;
            ilaufz=ilaufz+1;
            Data_read(:,:,ilaufz) = Data_read_xy;
            fseek(fid,2*(ydim*xdim-fseek_merker),0);
            fseek_merker=0;
        end;
    elseif magic(4)==4
    	for lauf=1:area(3)+1
		    tmp =  fread(fid,[ydim,xdim],'long');
    		Data_read(:,:,lauf) = tmp(nr(2):(nr(2)+area(2)),nr(1):(nr(1)+area(1)));
	    end;
    elseif magic(4)==5
        fseek_merker=0;
        fseek(fid,4*(nr(1)-1),0);
        fseek(fid,4*(xdim*(nr(2)-1)),0);
        fseek(fid,4*(ydim*xdim*(nr(3)-1)),0);
        for lauf=nr(3):nr(3)+area(3)
            for laufy=nr(2):(nr(2)+area(2))
                ilaufx=ilaufx+1;
    		    tmp = fread(fid,[area(1)+1],'float');
                Data_read_xy(:,ilaufx)=tmp;
                fseek(fid,4*(xdim-area(1)-1),0);
                fseek_merker=fseek_merker+xdim;
            end;
            ilaufx=0;
            ilaufz=ilaufz+1;
            Data_read(:,:,ilaufz) = Data_read_xy;
            fseek(fid,4*(ydim*xdim-fseek_merker),0);
            fseek_merker=0;
        end;
    elseif magic(4)==8
	    for lauf=1:area(3)+1
		    tmp = fread(fid,[ydim,xdim],'float64');
    		Data_read(:,:,lauf) = tmp(nr(2):(nr(2)+area(2)),nr(1):(nr(1)+area(1)))';
	    end;
    else
        disp('Sorry, i cannot read this as an EM-File !!!');
        Data_read=[];
    end;

    if readsize_x~=nr(1)+area(1) | readsize_y~=nr(2)+area(2) | readsize_z~=nr(3)+area(3)
        Data_read_intended=zeros(area_intended(1)+1,area_intended(2)+1,area_intended(3)+1);
        Data_read_intended=tom_paste(Data_read_intended,Data_read,[1 1]);
        Data_read=Data_read_intended;
    end;
end;
fclose(fid); % bug fixed FF


if parameter(8)<0 || parameter(8)>6 parameter(8)=0;end;

if findstr(em_name,'\')
    filename=em_name(max(findstr(em_name,'\'))+1:size(em_name,2));
    pathname=em_name(1:max(findstr(em_name,'\')));
else
    filename=em_name;
    pathname=[pwd '\'];
    
end



if magic(3)==1;
Data=Data_read;
else
EM=struct('Magic',magic,'Size',image_size,'Comment',comment,'Parameter',parameter,'Fillup',fillup);
Header=struct(...
    'Voltage',parameter(1),...
    'Cs',parameter(2)./1000,...
    'Aperture',parameter(3),...
    'Magnification',parameter(4),...
    'Postmagnification',parameter(5)./1000,...
    'Exposuretime',parameter(6)./1000,...
    'Objectpixelsize',parameter(7)./1000,...
    'Microscope',emtype(parameter(8)+1),...
    'Pixelsize',parameter(9)./1000,...
    'CCDArea',parameter(10)./1000,...
    'Defocus',parameter(11),...
    'Astigmatism',parameter(12),...
    'AstigmatismAngle',parameter(13)./1000,...
    'FocusIncrement',parameter(14)./1000,...
    'CountsPerElectron',parameter(15)./1000,...
    'Intensity',parameter(16)./1000,...
    'EnergySlitwidth',parameter(17),...
    'EnergyOffset',parameter(18),...
    'Tiltangle',parameter(19)./1000,...
    'Tiltaxis',parameter(20)./1000,...
    'Marker_X',parameter(24),...
    'Marker_Y',parameter(25),...
    'Username',num2str(fillup(1:20)),...
    'Date',num2str(fillup(21:28)),...
    'Filename',filename,...
    'Pathname',pathname,...
    'Magic',magic,'Size',image_size,'Comment',comment,'Parameter',parameter,'Fillup',fillup,'EM',EM);
Data=struct('Value',Data_read,'Header',Header);
end;

clear Data_read;
clear tmp;

