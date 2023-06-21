function [Data] = tom_readmrcheader(em_name,format)
%Reads the header information of an MRC-file
%
%SYNTAX
%out=tom_readmrcheader
%out=tom_readmrcheader('source_file','le')
%
%DESCRIPTION
%Read the MRC file header of source_file and put the result in out. An option 'le' for little-endian, 
%or 'be' for big-endian can be added. 
%
%EXAMPLE
%i=tom_readmrcheader;
%A fileselect-box appears and the MRC-file can be picked. Open the file for little-endian only (PC format)
%
%i=tom_readmrcheader('c:\test\mrs_001.mrc','le'); 
%Open MRC file mrs_001.mrc in little-endian(PC) format.
%
%SEE ALSO
%TOM_MRCREAD, TOM_MRC2EM
%
%Copyright (c) 2005
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Ceated: 09/25/02 SN
%Last modified: 05/04/05 WDN
%
if nargin <1 
    [filename, pathname] = uigetfile({'*.mrc';'*.*'}, 'Pick an MRC-file');
    if isequal(filename,0) | isequal(pathname,0) 
        disp('No data loaded.'); return; 
    end;
    em_name=[pathname filename];
    format='le';
end;
if nargin==1
    error('Not enought input parameter');
end
if isequal(format,'le');
    fid = fopen(em_name,'r','ieee-le');
else
    fid = fopen(em_name,'r','ieee-be');
end;

if fid==-1
    error(['Cannot open: ' em_name ' file']); 
end;
Parameter.nx = fread(fid,[1],'int32');
Parameter.ny = fread(fid,[1],'int32');
Parameter.nz = fread(fid,[1],'int32');
Parameter.mode = fread(fid,[1],'int32');
Parameter.nxstart= fread(fid,[1],'int32');
Parameter.nystart= fread(fid,[1],'int32');
Parameter.nzstart= fread(fid,[1],'int32');
Parameter.mx= fread(fid,[1],'int32');
Parameter.my= fread(fid,[1],'int32');
Parameter.mz= fread(fid,[1],'int32');        % : integer;
Parameter.xlen= fread(fid,[1],'float');
Parameter.ylen= fread(fid,[1],'float');
Parameter.zlen= fread(fid,[1],'float');
Parameter.alpha= fread(fid,[1],'float');
Parameter.beta= fread(fid,[1],'float');
Parameter.gamma= fread(fid,[1],'float');     % : single;
Parameter.mapc= fread(fid,[1],'int32');
Parameter.mapr= fread(fid,[1],'int32');
Parameter.maps= fread(fid,[1],'int32');      %  : integer;
Parameter.amin= fread(fid,[1],'float');
Parameter.amax= fread(fid,[1],'float');
Parameter.amean= fread(fid,[1],'float');     %  : single;
Parameter.ispg= fread(fid,[1],'int32');
Parameter.nsymbt = fread(fid,[1],'int32');   % : integer;
Parameter.unk = fread(fid,[16],'int32');     %   : array[0..15] of integer; { this is unused junk }
Parameter.idtype= fread(fid,[1],'int32');    %   : integer;
Parameter.nd1= fread(fid,[1],'int16');
Parameter.nd2= fread(fid,[1],'int16');
Parameter.vd1= fread(fid,[1],'int16');
Parameter.vd2= fread(fid,[1],'int16');       %   : smallint;
Parameter.tiltangles= fread(fid,[9],'float');% : array[0..8] of single;
Parameter.zorg= fread(fid,[1],'float');
Parameter.xorg= fread(fid,[1],'float');
Parameter.yorg = fread(fid,[1],'float');     %   : single;
Parameter.nlabl = fread(fid,[1],'int32');    %    : integer;
Parameter.labl = fread(fid,[800],'char');    %   : array[0..9] of p80 end of std MRC format, rest is FEI special;
Parameter.a_tilt= fread(fid,[1],'float');
Parameter.b_tilt= fread(fid,[1],'float');
Parameter.x_stage= fread(fid,[1],'float');
Parameter.y_stage= fread(fid,[1],'float');
Parameter.z_stage= fread(fid,[1],'float');
Parameter.x_shift= fread(fid,[1],'float');
Parameter.y_shift= fread(fid,[1],'float');
Parameter.defocus= fread(fid,[1],'float');
Parameter.exp_time= fread(fid,[1],'float');
Parameter.mean_int= fread(fid,[1],'float');
Parameter.tiltaxis=fread(fid,[1],'float');
Parameter.pixelsize=fread(fid,[1],'float');
Parameter.magnification=fread(fid,[1],'float');
fseek(fid,-Parameter.nx.*Parameter.ny.*(Parameter.mode*2),1);
fclose(fid);
MRC=struct('Parameter',Parameter);
Header=struct('Size',[Parameter.nx Parameter.ny Parameter.nz]','MRC',MRC);
Data=struct('Header',Header);


