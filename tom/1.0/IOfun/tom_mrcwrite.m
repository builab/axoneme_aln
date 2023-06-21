function tom_mrcwrite(varargin)
%Writes data in an MRC-file format.
%
%SYNTAX
%tom_mrcwrite(mrc_name,Data,format)
%
%DESCRIPTION
%Writes an MRC-Image File a raw format with a 1024 Byte header. If input is
%not a structure a default header is created.
%
%Parameters
%mrc_name    :['PATHNAME' 'FILENAME'] of the output file
%Data        :Structure of Image Data
%format      :machine-byte-order  set format 'le' for little endian 
%             files (PC,Linux) or 'be' for big endian (SGI,Mac). 
%  
%EXAMPLE
%
%a fileselect-box appears and the data can be saved
%with the selected filename as little endian
%load clown;
%tom_mrcwrite(X,'le');
%
%Save X in test.mrc as big endian format
%load clown;
%tom_mrcwrite('test.mrc',X,'be');        
%
%SEE ALSO
%TOM_MRCREAD, TOM_EMWRITE, TOM_MRCSTACK2EMSERIES
%
%Copyright (c) 2004
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 09/25/02 SN
%Last modified: 17/05/05 WDN
%
if nargin<=1
    error(['Data not specified (e.g. tom_mrcwrite(out)']);
elseif nargin==2
    Data=varargin{1};
    format=varargin(2);    
    %Data=mrc_name;
    [filename, pathname] = uiputfile({'*.mrc';'*.*'}, 'Save as MRC-file');
    if isequal(filename,0) | isequal(pathname,0) disp('Data not saved.'); return; end;
    mrc_name=[pathname filename];
    if isempty(findstr('.mrc',mrc_name))
        mrc_name=[mrc_name '.mrc'];
    end
elseif nargin==3
    mrc_name=varargin{1};
    Data=varargin{2};
    format=varargin{3};    
end;

%if nargin <1 error(['Data not specified (e.g. tom_mrcwrite(out)']);  end;
MRC=struct('nx',0,'ny',0,'nz',0,'mode',0,...
    'nxstart',0,'nystart',0,'nzstart',0,...
    'mx',0,'my',0,'mz',0,...
    'xlen',0,'ylen',0,'zlen',0,...
    'alpha',90,'beta',90,'gamma',90,...
    'mapc',1,'mapr',2,'maps',3,...
    'amin',min(min(min(Data.Value))),'amax',min(min(min(Data.Value))),...
    'amean',mean(mean(mean(Data.Value))),...
    'ispg' ,0,'nsymbt',0,'next',0,...
    'creatid',0,'nint',0,'nreal',0,...
    'idtype',0,'lens',0,'nd1',0,'nd2',0,'vd1',0,'vd2',0,...
    'tiltangles',[0 0 0 0 0 0],...
    'xorg',0,'yorg',0,'zorg',0,...
    'cmap','MAP','stamp',[0 0 0 0],...
    'rms',0,'nlabl',1,'labl','');
if isstruct(Data)
    MRC.nx=size(Data.Value,1);
    MRC.ny=size(Data.Value,2);
    if size(Data.Value)>2
        MRC.nz=size(Data.Value,3);
    else
        MRC.nz=0;
    end
    if isa(Data.Value,'double') | isa(Data.Value,'single')
        MRC.mode=2;
    end;
    if isa(Data.Value,'int16') 
        MRC.mode=1;
    end;
    if isa(Data.Value,'int8') 
        MRC.mode=0;
    end;
    MRC.mx=MRC.nx;MRC.my=MRC.ny;MRC.mz=MRC.nz;
    MRC.xlen=MRC.nx;MRC.ylen=MRC.ny;MRC.zlen=MRC.nz;
%    if size(Data.Header.Comment,1)<800
%        fillup=char(zeros(800-size(Data.Header.Comment,1),1));
%    Data.Header.Comment=[Data.Header.Comment' fillup']';
%    end;
%    if size(Data.Header.Parameter,1)<52
%        fillup=zeros(52-size(Data.Header.Parameter,1),1);
%    Data.Header.Parameter=[Data.Header.Parameter' fillup']';
%    end;
%    if ndims(Data.Value)==1 Data.Header.Size=[size(Data.Value,1) 1 1]; end;
%    if ndims(Data.Value)==2 Data.Header.Size=[size(Data.Value,1) size(Data.Value,2) 1]; end;
%    if ndims(Data.Value)==3 Data.Header.Size=[size(Data.Value,1) size(Data.Value,2) size(Data.Value,3)]; end;
%    Data.Header.Parameter(14)=Data.Header.Tiltangle;
end;

if isstruct(Data)~=1
    if isa(Data,'double') | isa(Data,'single')
            MRC.mode=2;
    end;
    if isa(Data,'int16') 
          MRC.mode=1;
    end;
    if isa(Data,'int8') 
            MRC.mode=0;
    end;
    comment=char(zeros(800,1));
    parameter=zeros(52,1);
    if ndims(Data)==1 image_size=[size(Data,1) 1 1]; end;
    if ndims(Data)==2 image_size=[size(Data,1) size(Data,2) 1]; end;
    if ndims(Data)==3 image_size=[size(Data,1) size(Data,2) size(Data,3)]; end;
    Header=struct('Size',image_size','Comment',comment,'Parameter',parameter);
    Data=struct('Value',Data,'Header',Header);
    disp('Default MRC-header was created.');
end;

% open the stream always with the big endian format !
if isequal(format,'le');
    fid = fopen(mrc_name,'w','ieee-le');
else
    fid = fopen(mrc_name,'w','ieee-be');
end;

if fid==-1
    error(['Cannot open: ' mrc_name ' file']); 
end;
fwrite(fid,MRC.nx,'int');           %integer: 4 bytes
fwrite(fid,MRC.ny,'int');            %integer: 4 bytes
fwrite(fid,MRC.nz,'int');            %integer: 4 bytes
fwrite(fid,MRC.mode,'int');         %integer: 4 bytes
fwrite(fid,MRC.nxstart,'int');      %integer: 4 bytes
fwrite(fid,MRC.nystart,'int');      %integer: 4 bytes
fwrite(fid,MRC.nzstart,'int');      %integer: 4 bytes
fwrite(fid,MRC.mx,'int');           %integer: 4 bytes
fwrite(fid,MRC.my,'int');           %integer: 4 bytes
fwrite(fid,MRC.mz,'int');           %integer: 4 bytes
fwrite(fid,MRC.xlen,'float');       %float: 4 bytes
fwrite(fid,MRC.ylen,'float');       %float: 4 bytes
fwrite(fid,MRC.zlen,'float');       %float: 4 bytes
fwrite(fid,MRC.alpha,'float');      %float: 4 bytes
fwrite(fid,MRC.beta,'float');       %float: 4 bytes
fwrite(fid,MRC.gamma,'float');      %float: 4 bytes
fwrite(fid,MRC.mapc,'int');         %integer: 4 bytes
fwrite(fid,MRC.mapr,'int');         %integer: 4 bytes
fwrite(fid,MRC.maps,'int');         %integer: 4 bytes
fwrite(fid,MRC.amin,'float');       %float: 4 bytes
fwrite(fid,MRC.amax,'float');       %float: 4 bytes
fwrite(fid,MRC.amean,'float');      %float: 4 bytes
fwrite(fid,MRC.ispg,'short');       %integer: 2 bytes
fwrite(fid,MRC.nsymbt,'short');     %integer: 2 bytes
fwrite(fid,MRC.next,'int');         %integer: 4 bytes
fwrite(fid,MRC.creatid,'short');    %integer: 2 bytes
fwrite(fid,[30]);                   %not used: 30 bytes
fwrite(fid,MRC.nint,'short');       %integer: 2 bytes
fwrite(fid,MRC.nreal,'short');      %integer: 2 bytes
fwrite(fid,[28]);                   %not used: 28 bytes
fwrite(fid,MRC.idtype,'short');     %integer: 2 bytes
fwrite(fid,MRC.lens,'short');       %integer: 2 bytes
fwrite(fid,MRC.nd1,'short');        %integer: 2 bytes
fwrite(fid,MRC.nd2,'short');        %integer: 2 bytes
fwrite(fid,MRC.vd1,'short');        %integer: 2 bytes
fwrite(fid,MRC.vd2,'short');        %integer: 2 bytes
fwrite(fid,MRC.tiltangles,'float'); %float: 6*4 bytes=24 bytes
fwrite(fid,MRC.xorg,'float');       %float: 4 bytes
fwrite(fid,MRC.yorg,'float');       %float: 4 bytes
fwrite(fid,MRC.zorg,'float');       %float: 4 bytes
fwrite(fid,MRC.cmap,'char');        %Character: 4 bytes
fwrite(fid,MRC.stamp,'char');       %Character: 4 bytes
fwrite(fid,MRC.rms,'float');        %float: 4 bytes
fwrite(fid,MRC.nlabl,'int');        %integer: 4 bytes
fwrite(fid,MRC.labl,'char');        %Character: 800 bytes
xdim = Data.Header.Size(1);
ydim = Data.Header.Size(2);
zdim = Data.Header.Size(3);
for lauf=1:zdim
	Data_write=Data.Value(1:xdim,1:ydim,lauf);
	if MRC.mode==0
		fwrite(fid,Data_write,'int8');
	elseif MRC.mode==1
		fwrite(fid,Data_write,'int16');
	elseif MRC.mode==2
		fwrite(fid,Data_write,'float');
	else
		disp('Sorry, i cannot write this as an EM-File !!!');
	end;
end;


fclose(fid);
