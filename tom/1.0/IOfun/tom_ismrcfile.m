function [out] = tom_ismrcfile(em_name)
%Checks if the file is in MRC-file format
%
%SYNTAX
%i=tom_ismrcfile('holderCryo2.mrc')
%
%DESCRIPTION
%Check if the file exists, if the file contains a 1024 byte eader and a 
%extended header. Returns 1 if Filename is an MRC-file, 0 if it is not an
%MRC-file and -1 if Filename doesn't exist at all.
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
%Symmetry records follow - if any - stored as text as in International
%Tables, operators separated by * and grouped into 'lines' of 80
%characters (ie. symmetry operators do not cross the ends of the
%80-character 'lines' and the 'lines' do not terminate in a *).
%
%Data records follow.
%
%In general, the X-Y origin is taken as 0,0 being in the
%lower-left corner of the image AND the first data point in the file
%(normally corresponding to array element 1,1).
%
%                  Top of Image             1,NY     Array    NX,NY
%         ^ !                                ^ !
%         ! !                                ! !
%         ! !                                ! !
%         y !                                y !
%           !_____________   x-->              !_______________  x-->
%         0,0                                 1,1             NX,1
%
%
%Complex images are not supported!
%
%EXAMPLE
%i=tom_ismrcfile('holderCryo2.mrc')
%
%SEE ALSO
%TOM_MRCREAD, TOM_MRC2EM, TOM_ISEMFILE
%
%Copyright (c) 2005
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 10/21/02 SN
%Last modified: 13/05/05 WDN
%

% open the stream with the correct format !
fid = fopen(em_name,'r','ieee-le');
if fid==-1
    out=-1;
    return;
end;
xdim = fread(fid,[1],'int');    %integer: 4 bytes
ydim = fread(fid,[1],'int');    %integer: 4 bytes
zdim = fread(fid,[1],'int');    %integer: 4 bytes
MODE = fread(fid,[1],'int');    %integer: 4 bytes
fseek(fid, 92, 'bof'); %go to the param next
next = fread(fid,[1],'int');	%integer: 4 bytes
out=1;
fseek(fid,0,'eof'); %go to the end of file
if MODE==0
    position=ftell(fid);
    if position~=(xdim.*ydim.*zdim)+1024+next
        out=0;
    end;
elseif  MODE==1
    position=ftell(fid);
    if position~=(2.*xdim.*ydim.*zdim)+1024+next
        out=0;
    end;
elseif MODE==2
    position=ftell(fid);
    if position~=(4.*xdim.*ydim.*zdim)+1024+next
        out=0;
    end;
else
    out=0;
end;

fclose(fid);
