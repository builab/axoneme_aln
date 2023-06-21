function [Data] = tom_mrcread(em_name,format)
%Reads data in MRC-file format
%
%SYNTAX 
%i=tom_mrcread
%i=tom_mrcread('Proj.mrc','le');
%
%DESCRIPTION
%Reads a 2D or 3D MRC file format. A raw format with a 1024 Bytes header. If there is no input, 
%then a dialog box appears to select a file. Works for little endian format only!
%
%Structure of MRC-data files:
%MRC Header has a length of 1024 bytes
% SIZE  DATA    NAME    DESCRIPTION
%   4   int     NX      number of Columns    (fastest changing in map)
%   4   int     NY      number of Rows
%   4   int     NZ      number of Sections   (slowest changing in map)
%   4   int     MODE    Types of pixel in image
%                       0 = Image     unsigned bytes
%                       1 = Image     signed short integer (16 bits)
%                       2 = Image     float
%                       3 = Complex   short*2
%                       4 = Complex   float*2     
%	4   int     NXSTART Number of first COLUMN  in map (Default = 0)
%   4   int     NYSTART Number of first ROW     in map      "
%   4   int     NZSTART Number of first SECTION in map      "
%   4   int     MX      Number of intervals along X
%   4   int     MY      Number of intervals along Y
%   4   int     MZ      Number of intervals along Z
%   4   float   Xlen    Cell Dimensions (Angstroms)
%   4   float   Ylen                 "
%   4   float   Zlen                 "
%   4   float   ALPHA   Cell Angles (Degrees)
%   4   float   BETA                 "
%   4   float   GAMMA                "
%   4   int     MAPC    Which axis corresponds to Columns  (1,2,3 for X,Y,Z)
%   4   int     MAPR    Which axis corresponds to Rows     (1,2,3 for X,Y,Z)
%   4   int     MAPS    Which axis corresponds to Sections (1,2,3 for X,Y,Z)
%   4   float   AMIN    Minimum density value
%   4   float   AMAX    Maximum density value
%   4   float   AMEAN   Mean    density value    (Average)
%   2   short   ISPG    Space group number       (0 for images)
%   2   short   NSYMBT  Number of bytes used for storing symmetry operators
%   4   int     NEXT    Number of bytes in extended header
%   2   short   CREATID Creator ID
%   30    -     EXTRA   Not used. All set to zero by default
%   2   short   NINT    Number of integer per section
%   2   short   NREAL   Number of reals per section
%   28    -     EXTRA2  Not used. All set to zero by default
%   2   short   IDTYPE  0=mono, 1=tilt, 2=tilts, 3=lina, 4=lins
%   2   short   LENS    
%   2   short   ND1   
%   2   short   ND2
%   2   short   VD1 
%   2   short   VD2
%   24  float   TILTANGLES
%   4   float   XORIGIN X origin
%   4   float   YORIGIN Y origin
%   4   float   ZORIGIN Z origin
%   4   char    CMAP    Contains "MAP "
%   4   char    STAMP   
%   4   float   RMS 
%   4   int     NLABL   Number of labels being used
%   800 char    10 labels of 80 character
%
%EXAMPLE
%i=tom_mrcread  a fileselect-box appears and the EM-file can be picked
%               default format: 'le',little endion (PC)
%i=tom_mrcread('Proj.mrc'); default format: 'le',little endion (PC)
%i=tom_mrcread('Proj.mrc','le'); open file in little-endian(PC) format.
%
%SEE ALSO
%TOM_EMREAD, TOM_SPIDERREAD
% 
%Copyright (c) 2005
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 09/25/02 SN
%Last change: 13/05/05 WDN
%

error(nargchk(0,2,nargin))
if nargin <1 
    [filename, pathname] = uigetfile({'*.mrc';'*.*'}, 'Pick an MRC-file');
    if isequal(filename,0) | isequal(pathname,0) 
        disp('No data loaded.'); return; 
    end;
    em_name=[pathname filename];
    format='le';
end;
if nargin==1 %default format: le
    format='le';
end
if isequal(format,'le');
    fid = fopen(em_name,'r','ieee-le');
else
    fid = fopen(em_name,'r','ieee-be');
end;
if fid==-1
    error(['Cannot open: ' em_name ' file']); 
end;
MRC.nx = fread(fid,[1],'int');        %integer: 4 bytes
MRC.ny = fread(fid,[1],'int');        %integer: 4 bytes
MRC.nz = fread(fid,[1],'int');        %integer: 4 bytes
MRC.mode = fread(fid,[1],'int');      %integer: 4 bytes
MRC.nxstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nystart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.nzstart= fread(fid,[1],'int');    %integer: 4 bytes
MRC.mx= fread(fid,[1],'int');         %integer: 4 bytes
MRC.my= fread(fid,[1],'int');         %integer: 4 bytes
MRC.mz= fread(fid,[1],'int');         %integer: 4 bytes
MRC.xlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.ylen= fread(fid,[1],'float');     %float: 4 bytes
MRC.zlen= fread(fid,[1],'float');     %float: 4 bytes
MRC.alpha= fread(fid,[1],'float');    %float: 4 bytes
MRC.beta= fread(fid,[1],'float');     %float: 4 bytes
MRC.gamma= fread(fid,[1],'float');    %float: 4 bytes
MRC.mapc= fread(fid,[1],'int');       %integer: 4 bytes
MRC.mapr= fread(fid,[1],'int');       %integer: 4 bytes
MRC.maps= fread(fid,[1],'int');       %integer: 4 bytes
MRC.amin= fread(fid,[1],'float');     %float: 4 bytes
MRC.amax= fread(fid,[1],'float');     %float: 4 bytes
MRC.amean= fread(fid,[1],'float');    %float: 4 bytes
MRC.ispg= fread(fid,[1],'short');     %integer: 2 bytes
MRC.nsymbt = fread(fid,[1],'short');  %integer: 2 bytes
MRC.next = fread(fid,[1],'int');      %integer: 4 bytes
MRC.creatid = fread(fid,[1],'short'); %integer: 2 bytes
MRC.unused1 = fread(fid,[30]);        %not used: 30 bytes
MRC.nint = fread(fid,[1],'short');    %integer: 2 bytes
MRC.nreal = fread(fid,[1],'short');   %integer: 2 bytes
MRC.unused2 = fread(fid,[28]);        %not used: 28 bytes
MRC.idtype= fread(fid,[1],'short');   %integer: 2 bytes
MRC.lens=fread(fid,[1],'short');      %integer: 2 bytes
MRC.nd1=fread(fid,[1],'short');       %integer: 2 bytes
MRC.nd2 = fread(fid,[1],'short');     %integer: 2 bytes
MRC.vd1 = fread(fid,[1],'short');     %integer: 2 bytes
MRC.vd2 = fread(fid,[1],'short');     %integer: 2 bytes
for i=1:6                               %24 bytes in total
    MRC.tiltangles(i)=fread(fid,[1],'float');%float: 4 bytes
end
MRC.xorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.yorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.zorg = fread(fid,[1],'float');    %float: 4 bytes
MRC.cmap = fread(fid,[4],'char');     %Character: 4 bytes
MRC.stamp = fread(fid,[4],'char');    %Character: 4 bytes
MRC.rms=fread(fid,[1],'float');       %float: 4 bytes
MRC.nlabl = fread(fid,[1],'int');     %integer: 4 bytes
MRC.labl = fread(fid,[800],'char');   %Character: 800 bytes
if MRC.nz>1
    Data_read=zeros(MRC.nx,MRC.ny,1);
else
    Data_read=zeros(MRC.nx,MRC.ny,1);
end
Extended.a_tilt= fread(fid,[1],'float');
Extended.b_tilt= fread(fid,[1],'float');
Extended.x_stage= fread(fid,[1],'float');
Extended.y_stage=fread(fid,[1],'float');
Extended.z_stage=fread(fid,[1],'float');
Extended.x_shift=fread(fid,[1],'float');
Extended.y_shift=fread(fid,[1],'float');
Extended.defocus=fread(fid,[1],'float');
Extended.exp_time=fread(fid,[1],'float');
Extended.mean_int=fread(fid,[1],'float');
Extended.tiltaxis=fread(fid,[1],'float');
Extended.pixelsize=fread(fid,[1],'float');
Extended.magnification=fread(fid,[1],'float'); % : single
fseek(fid,0,'eof'); %go to the end of file
fprintf('loading');
for i=1:MRC.nz
    fprintf('.');
    if MRC.mode==0
        beval=MRC.nx*MRC.ny*MRC.nz;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,i) = fread(fid,[MRC.nx,MRC.ny],'int8');
    elseif MRC.mode==1
        beval=MRC.nx*MRC.ny*MRC.nz*2;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,i) = fread(fid,[MRC.nx,MRC.ny],'int16');
    elseif MRC.mode==2
        beval=MRC.nx*MRC.ny*MRC.nz*4;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,i) = fread(fid,[MRC.nx,MRC.ny],'float');
    else
        error(['Sorry, i cannot read this as an MRC-File !!!']);
        Data_read=[];
    end
end
disp('.');
disp('done');
fclose(fid);
Header=struct(...
    'Voltage',0,...
    'Cs',0,...
    'Aperture',0,...
    'Magnification',Extended.magnification,...
    'Exposuretime',Extended.exp_time,...
    'Objectpixelsize',Extended.pixelsize.*1e9,...
    'Microscope',0,...
    'Pixelsize',0,...
    'CCDArea',0,...
    'Defocus',Extended.defocus,...
    'Astigmatism',0,...
    'AstigmatismAngle',0,...
    'FocusIncrement',0,...
    'CountsPerElectron',0,...
    'Intensity',0,...
    'EnergySlitwidth',0,...
    'EnergyOffset',0,...
    'Tiltangle',Extended.a_tilt,...
    'Tiltaxis',Extended.tiltaxis,...
    'Username',num2str(zeros(20,1)),...
    'Date',num2str(zeros(8)),...
    'Size',[MRC.nx,MRC.ny,MRC.nz],...
    'Comment',num2str(zeros(80,1)),...
    'Parameter',num2str(zeros(40,1)),...
    'Fillup',num2str(zeros(256,1)),...
    'Filename',em_name,...
    'Postmagnification',0,...
    'Marker_X',0,...
    'Marker_Y',0,...
    'MRC',MRC);

Data=struct('Value',Data_read,'Header',Header);

clear Data_read;
