function tom_mrcstack2emseries(mrc_file,em_series,extension,format)
%Converts a MRC (FEI style) stack (i.e. a tiltseries) in a series of
%numbered EM-Image Files (V-Format). 
%
%SYNTAX
%tom_mrcstack2emseries(mrc_file,em_series,extension,format)
%
%DESCRIPTION
%tom_mrcstack2emseries converts a MRC(FEI style) stack into a series of
%numbered EM-Images by reading the header and then the images.
%
%mrc_file       :mrc input file
%em_series      :name of the output files
%extension      :extension of the output files   
%format         :machine-byte-order  set format 'le' for little endian 
%                files (PC,Linux) or 'be' for big endian (SGI,Mac). 
%  
%EXAMPLE
%tom_mrcstack2emseries('A_03.mrc','newA_03_','em','le');
%
%SEE ALSO 
%TOM_MRC2EM, TOM_MRCREAD, TOM_EMWRITE
%
%Copyright (c) 2004
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 08/01/04 SN
%Last modification: 17/05/05 WDN
%

if isequal(format,'le');
    fid = fopen(mrc_file,'r','ieee-le');
else
    fid = fopen(mrc_file,'r','ieee-be');
end;

if ~isempty(findstr(em_series,'_'))
    if em_series(size(em_series,2))~='_'    %last letter
        em_series=strcat(em_series,'_');
    end        
else
    em_series=strcat(em_series,'_');
end

if fid==-1
    error(['Cannot open: ' mrc_file ' file']); 
end;
%Read header og 1024 bytes
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
for i=1:6   %24 bytes in total
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
Data_read=zeros(MRC.nx,MRC.ny,1);
for lauf=1:MRC.nz
    Extended(lauf).a_tilt= fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).b_tilt= fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).x_stage= fread(fid,[1],'float'); %float: 4 bytes
    Extended(lauf).y_stage=fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).z_stage=fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).x_shift=fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).y_shift=fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).defocus=fread(fid,[1],'float');  %float: 4 bytes
    Extended(lauf).exp_time=fread(fid,[1],'float'); %float: 4 bytes
    Extended(lauf).mean_int=fread(fid,[1],'float'); %float: 4 bytes
    Extended(lauf).tiltaxis=fread(fid,[1],'float'); %float: 4 bytes
    Extended(lauf).pixelsize=fread(fid,[1],'float').*10^9;  %float: 4 bytes
    Extended(lauf).magnification=fread(fid,[1],'float');	%float: 4 bytes
    fseek(fid,128-52,0);%total of bytes: 52
end;
fseek(fid,0,'eof'); %go to the end of file
disp('Start conversion a MRC stack to an EM series.')
for lauf2=1:MRC.nz
    if MRC.mode==0
        beval=MRC.nx*MRC.ny*MRC.nz;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,1) = fread(fid,[MRC.nx,MRC.ny],'int8');
    elseif MRC.mode==1
        beval=MRC.nx*MRC.ny*MRC.nz*2;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,1) = fread(fid,[MRC.nx,MRC.ny],'int16');
    elseif MRC.mode==2
        beval=MRC.nx*MRC.ny*MRC.nz*4;
        fseek(fid,-beval,0); %go to the beginning of the values
        Data_read(:,:,1) = fread(fid,[MRC.nx,MRC.ny],'float');
    else
        error(['Sorry, i cannot read this as an MRC-File !!!']);
        Data_read=[];
    end;
    Data=tom_emheader(Data_read);
    Data.Header.Magnification=Extended(lauf2).magnification;
    Data.Header.Exposuretime=Extended(lauf2).exp_time;
    Data.Header.Objectpixelsize=Extended(lauf2).pixelsize;
    Data.Header.Defocus=Extended(lauf2).defocus;
    Data.Header.Tiltangle=Extended(lauf2).a_tilt;
    Data.Header.Tiltaxis=Extended(lauf2).tiltaxis;
    tom_emwrite([em_series num2str(lauf2) '.' extension],Data);
    disp([em_series num2str(lauf2) '.' extension ' ............done'])
end
disp('Conversion done.');
fclose(fid);

clear Data_read;

