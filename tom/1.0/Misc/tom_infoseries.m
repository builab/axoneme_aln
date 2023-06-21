function tom_infoseries(em_name)

% TOM_INFOSERIES generates a documentation output
%
%    10/14/02 SN
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


error(nargchk(0,1,nargin))
if nargin <1 
[filename, pathname] = uigetfile('*.alg', 'Load alignment file');  
if isequal(filename,0) | isequal(pathname,0) disp('No data loaded.'); return; 
else
    mm=fopen([pathname filename],'r');
    textp=fscanf(mm,'%c',79);
    textp=fscanf(mm,'%s\n',1);mypathname=textp
    textp=fscanf(mm,'%s\n',1);myfilename=textp
    textp=fscanf(mm,'%s\n',1);myfirstnb=textp
    textp=fscanf(mm,'%s\n',1);mylastnb=textp
    textp=fscanf(mm,'%s\n',1);myext=textp
    textp=fscanf(mm,'%s\n',1);myfilemarker_default=textp
    textp=fscanf(mm,'%s\n',1);myfilemarker=textp
    textp=fscanf(mm,'%s\n',1);image_ref=textp
    textp=fscanf(mm,'%s\n',1);newproj_cancel=textp
    textp=fscanf(mm,'%s\n',1);
    textp=fscanf(mm,'%s\n',1);
    textp=fscanf(mm,'%s\n',1);
    textp=fscanf(mm,'%s\n',1);
end;
end;
fclose(mm);
em_name=[mypathname myfilename image_ref myext];
i=tom_emread([mypathname myfilename image_ref myext]);
if i.Header.Size(1)>1024 i.Value=i.Value(1:2:i.Header.Size(1),1:2:i.Header.Size(1));
    i.Header.Size(1)=i.Header.Size(1)./2;
    i.Header.Size(2)=i.Header.Size(2)./2;
end;
    
u=ones(1024,2048).*max(max(i.Value));
uu=tom_paste(u,i.Value,[1 1]);
figure;
imagesc(uu');axis off;
colormap gray;axis image;drawnow;hold on;
head=1100;
text(20,head,'Tiltseries Information:','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+100;
text(20,head,'Reference projection image:','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,[em_name],'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
set(gcf,'PaperPosition',[0.634518 0.634518 19.715 28.4084])
set(gcf,'PaperOrientation','portrait')
set(gcf,'PaperUnits','centimeters')

% open the stream with the correct format !
fid = fopen(em_name,'r','ieee-be');
if fid==-1
    error(['Cannot open: ' em_name ' file']); 
end;
magic = fread(fid,[4],'char');
fclose(fid);

switch(magic(1))
    case 6
        disp('The data was generated at an PC.');
    case 5
        disp('The data was generated at an Mac.');
    case 3
        disp('The data was generated at an SGI.');
    case 2
        disp('The data was generated at an Convex.');
    case 1
        disp('The data was generated at an VAX.');
    case 0
        disp('The data was generated at an OS-9.');
end;
% reads the header
%
% description in 'The Structure of the EM-Data Files', Herr Hegerl
% and at the bottom of this file

% read the Header 
if (magic(1)==3 | magic(1)==0 | magic(1)==5)
fid = fopen(em_name,'r','ieee-be'); % for SGI or OS-9 or Mac
else
fid = fopen(em_name,'r','ieee-le'); % for PC
end;    
magic = fread(fid,[4],'char');
image_size = fread(fid,[3],'int32');
text(20,head,['Size: ' num2str(image_size(1)) ' ' num2str(image_size(2)) ' '] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
comment = fread(fid,[80],'char');
parameter = fread(fid,[40],'int32');
disp('Parameter:');
text(20,head,['Magnification: ' num2str(parameter(4))],'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['Exposure time: ' num2str(parameter(6))],'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['Pixelsize obj: ' num2str(parameter(7))],'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
switch(parameter(8))
    case 6
        text(20,head,'The data was acquiered at the Tecnai Polara/GIF2002.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
    case 5
        text(20,head,'The data was acquiered at the CM300/GIF2002.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
    case 4
        text(20,head,'The data was acquiered at the CM120/Biofilter.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
    case 3
        text(20,head,'The data was acquiered at the CM200.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
    case 2
        text(20,head,'The data was acquiered at the CM12.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
    case 1
        text(20,head,'The data was acquiered at the EM420.','FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
end;
text(20,head,['Tiltangle    : ' num2str(parameter(19)./1000) ' °'],'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;


fillup = fread(fid,[256],'char');

% the size of the image
%text(20,head,['Comment: ' char(comment)'] ,'Fontsize',12,'Fontweight','bold');head=head+50;

if magic(4)==1
    disp(['Datatype is char.'])
elseif magic(4)==2
    disp(['Datatype is short.'])
elseif magic(4)==4
    disp(['Datatype is long.'])
elseif magic(4)==5
    disp(['Datatype is float.'])
elseif magic(4)==8
    disp(['Datatype is complex.'])
else
    error(['Sorry, i cannot read this as an EM-File !!!']);
end;
fclose(fid);
head=head+100;
text(20,head,['Alignment info:'] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+100;
m=tom_emread(myfilemarker);
Matrixmark=m.Value;
r=[0 0 0 ];
[Matrixmark, psi, sigma, x, y, z]  = tom_alignment3d(Matrixmark, 1, image_ref, r, image_size(1));
text(20,head,['Number of tilts:..............  = ' num2str(size(Matrixmark,2))] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['minimum tilt: projection number = ' num2str(image_ref)] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['Total number of marker points   = ' num2str(size(Matrixmark,3))] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['Number of reference point:....  = ' num2str(1)] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['Tilt axis azimuth:............  = ' num2str(psi) ' deg'] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
text(20,head,['RMS error fit:................  = ' num2str(sigma) ' pix'] ,'FontName','FixedWidth','Fontsize',12,'Fontweight','bold');head=head+50;
for lauf=1:size(Matrixmark,3)
    text(Matrixmark(2,str2num(image_ref),lauf)-18,Matrixmark(3,str2num(image_ref),lauf)+8,['o' num2str(lauf) ] ,'FontName','FixedWidth','Fontsize',22,'Fontweight','bold');
end;

%printdlg('-setup',gcf);
