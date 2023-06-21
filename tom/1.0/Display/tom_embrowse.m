function varargout = tom_embrowse(varargin)
% TOM_EMBROWSE is a tool to view EM files.
%      With tom_embrowse, the user can easily have a preview
%      visualization of his images (EM format). The user just 
%      have to select in the list boxes the file he wants to 
%      visualize. 
%      
%      Syntaxe: tom_embrowse
%       Input:
%           -
%       Output:
%           - 
%      See also: GUIDE, GUIDATA, GUIHANDLES, TOM_ISEMFILE, TOM_EMREADC
% 
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
%
%      Created: 15/01/03 William Del Net
%      Last modification: 05/02/04 William Del Net
% 

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_embrowse_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_embrowse_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tom_embrowse is made visible.
function tom_embrowse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_embrowse (see VARARGIN)

% Choose default command line output for tom_embrowse
handles.output = hObject;
handles.InitialPath=pwd;
handles.Path=pwd;
handles.Filename='';
handles.rnb=1;
% Update handles structure
guidata(hObject, handles);

if nargin == 3,
    initial_dir = pwd;
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end
% Populate the listbox
load_listbox(initial_dir,handles)
% Return figure handle as first output argument

% UIWAIT makes tom_embrowse wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tom_embrowse_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ----------------------------------------------------------
% ----------------------------------------------------------
% --- BUTTON ... (BROWSE) ---
function browse_Callback(hObject, eventdata, handles)
p = uigetdir;
if isequal(p,0)
    %nothing because Cancel is ckicked
else
	load_listbox(p,handles);
	handles.Path=p;
	handles.Filename='';
	guidata(hObject,handles);
end

% --- LIST BOX ---
function varargout = listbox1_Callback(hObject, eventdata, handles)
if strcmp(get(handles.figure1,'SelectionType'),'normal')%'open'
	index_selected = get(handles.listbox1,'Value');
	file_list = get(handles.listbox1,'String');	
	filename = [handles.Path '/' file_list{index_selected}];
    file= file_list{index_selected};
    [path,name,ext,ver] = fileparts(filename);
    emfile=tom_isemfile(filename);               
    if emfile==1%filename is an em File        
        info=tom_reademheader(filename);                
        set(handles.name,'String',file);
        set(handles.size,'String',[num2str(info.Header.Size(1)) ' x ' num2str(info.Header.Size(2)) ' x ' num2str(info.Header.Size(3))]);
        set(handles.angle,'String',[info.Header.Parameter(19)./1000.0]); 
        set(handles.tiltaxis,'String',info.Header.Tiltaxis); 
        set(handles.defocus,'String',info.Header.Defocus);
        set(handles.objpixsize,'String',info.Header.Objectpixelsize);
        if info.Header.Size(3)>1%for volume
            i=tom_emread(filename,'subregion',[1 1 round(info.Header.Size(3)/2)],[info.Header.Size(1)-1 info.Header.Size(2)-1 0]);
            set(handles.error,'String','No error. Middle of the volume displayed');
        else
            i=tom_emreadc(filename);
            set(handles.error,'String','No error');
        end
        s=size(i.Value);
        f=s(1)/256;
        %if size(s,2)==3%volume
            %set(handles.error,'String','No error. Volume 3D. Can not display it');
            %disp_im(0);        
        if f>=1%resize if image's size >256
            i.Value=i.Value(1:f:i.Header.Size(1),1:f:i.Header.Size(2),1); 
            disp_im(i.Value);           
        elseif info.Header.Size(1)==10%markerfile
            disp_im(0);                        
            set(handles.error,'String','Marker file'); 
        else
            disp_im(i.Value);                        
        end  
        handles.Filename=file;
    elseif isdir(filename)%filename is a directory
        switch file
            case '.'
                filename = handles.Path;
                load_listbox(filename,handles);
            case '..'
                cd (handles.Path);
                cd ('..');
                filename=pwd;
                load_listbox(filename,handles);
            otherwise
                load_listbox(filename,handles);                
        end
        handles=guidata(handles.figure1);
        handles.Filename='';
        disp_im(0);
    else
        if ~isempty(findstr(filename,'.bmp'))|~isempty(findstr(filename,'.tif'))|~isempty(findstr(filename,'.tiff'))|~isempty(findstr(filename,'.png'))|~isempty(findstr(filename,'.jpeg'))|~isempty(findstr(filename,'.jpg'))
            i.Value= imread(filename);
            i.Header=imfinfo(filename);
            s=size(i.Value);
            if s(1)>256 | s(2)>256
                if s(1)>=s(2)
                    fact=s(1)/256;
                    mrows=round(s(1)/fact);
                    ncols=round(s(2)/fact);
                else
                    fact=s(2)/256;
                    mrows=round(s(1)/fact);
                    ncols=round(s(2)/fact);
                end
                i.Value=imresize(i.Value,[mrows ncols],'nearest');
            end
            %i.Value=i.Value(1:f:s(1),1:f:s(2),1);
            imagesc(i.Value);
            axis image;
            set(handles.name,'String',file);
            set(handles.size,'String',[num2str(i.Header.Height) ' x ' num2str(i.Header.Width) ' x 1']);
            set(handles.angle,'String',''); 
            set(handles.tiltaxis,'String',''); 
            set(handles.defocus,'String','');
            set(handles.objpixsize,'String','');            
            set(handles.error,'String',['No error']); 
            axis image;
            handles.Filename=file;
        else    
            set(handles.error,'String','ERROR! Not an EM file');
            set(handles.name,'String',file);
            set(handles.size,'String','');
            set(handles.angle,'String',''); 
            disp_im(0);      
        end
    end    
    guidata(hObject,handles);
end

% --- BUTTON VIEW ---
function view_Callback(hObject, eventdata, handles)
filename=[handles.Path '\' handles.Filename];
sss=tom_isemfile(filename);
if sss
    i=tom_emreadc(filename);i.Value=tom_norm(double(i.Value),1);
else
    i.Value=imread(filename);
    i.Header=imfinfo(filename);
end
[mean, max, min, std, variance] = tom_devinternal(i.Value);
v=version;
if findstr(v,'6.5.0')%Matlab version 6.5.0       
    m=figure;set(0,'CurrentFigure',m);
    set(m,'NumberTitle','off','Name',filename);
    if sss==0
        %figure;        
        imshow(i.Value);    
    elseif (mean-2*std)>=(mean+3*std)                
        imshow(i.Value');
	else
        imshow(i.Value',[mean-(3*std) mean+(3*std),]);
	end
    t=title(['Info: (' num2str(size(i.Value)) ') pixel, mean:' num2str(mean,3) ' std:' num2str(std,3) ]);
    
else %Matlab version 6.5.1 ou more (if version 6.4.x or less, then bug)
    if size(i.Value,1)>2048 | size(i.Value,2)>2048 %image >2048 use imshow
        m=figure;set(0,'CurrentFigure',m);
        set(m,'NumberTitle','off','Name',filename); 
        if sss==0
            %figure;
            imshow(i.Value);                    
        elseif (mean-2*std)>=(mean+3*std)
            imshow(i.Value');
        else
            imshow(i.Value',[mean-(3*std) mean+(3*std),]);
        end 
        t=title(['Info: (' num2str(size(i.Value)) ') pixel, mean:' num2str(mean,3) ' std:' num2str(std,3) ]);
    else% otherwise, imview
        v=version;
        if findstr(v,'7.0.4') | findstr(v,'7.0.1')
            if sss==0
                vv=imtool(i.Value,'InitialMagnification','fit');
            elseif (mean-2*std)>=(mean+3*std)
                vv=imtool(i.Value','InitialMagnification','fit');
            else
                vv=imtool(i.Value',[mean-(3*std) mean+(3*std)],'InitialMagnification','fit');
            end
            set(vv,'NAME',[handles.Filename '  ' 'mean:' num2str(mean,3) ' std:' num2str(std,3) ]);
        else            
            if sss==0
                v=imview(i.Value,'InitialMagnification','fit');                    
            elseif (mean-2*std)>=(mean+3*std)
                v=imview(i.Value','InitialMagnification','fit');
            else
                v=imview(i.Value',[mean-(3*std) mean+(3*std)],'InitialMagnification','fit');            
            end 
            set(v,'Title',[filename '  ' 'mean:' num2str(mean,3) ' std:' num2str(std,3) ]);
        end
    end  
    
end

% --- BUTTON COPY TO WORKSPACE ---
function workspace_Callback(hObject, eventdata, handles)
filename=[handles.Path '/' handles.Filename];
sss=tom_isemfile(filename);
if sss
    i=tom_emreadc(filename);i.Value=double(i.Value);
    if i.Header.Size(3)>1 %volume
        var1=['vol_' num2str(handles.rnb)];
    else %image
        var1=['img_' num2str(handles.rnb)];
    end    
else
    i.Value=imread(filename);
    i.Header=imfinfo(filename);
    var1=['img_' num2str(handles.rnb)];
end
handles.rnb=handles.rnb+1;
assignin('base',var1,i);
guidata(hObject, handles);


% --- BUTTON PRINT ---
function print_Callback(hObject, eventdata, handles)
filename=[handles.Path '\' handles.Filename];
i=tom_emreadc(filename);i.Value=double(i.Value);
[mean, max, min, std, variance] = tom_devinternal(i.Value);
m=figure('Papertype','A4','Visible','off');set(0,'CurrentFigure',m);
set(m,'NumberTitle','off','Name',filename);
if (mean-2*std)>=(mean+3*std)               
    imshow(i.Value');                
else
    imshow(i.Value',[mean-(3*std) mean+(3*std),]);
end  
t=title([ filename ', Info: (' num2str(size(i.Value)) '), mean:' num2str(mean,3) ', std:' num2str(std,3) ]);
print (m) ;
close(m);

% --- BUTTON EXPORT ---
function export_Callback(hObject, eventdata, handles)
filename = [handles.Path '\' handles.Filename];
if tom_isemfile(filename)
ext = {'*.tif','Tagged Image File Format (*.tif)';'*.jpg', 'Joint Photographic Experts Group (*.jpg)';...
       '*.bmp','Windows Bitmap (*.bmp)';'*.png','Portable Network Graphics (*.png)'};
[myfile,mypathname,index] = uiputfile(ext,'Save File Name As',handles.Filename); 
	if isequal(myfile,0) | isequal(mypathname,0)
        %nothing because Cancel is ckicked
	else 
        if any(findstr(myfile,'.'))
            myext='';
        else
            myext=ext{index}(2:end);
        end        
        copyto=[mypathname myfile myext];
        i=tom_emread(filename);
        if findstr(copyto,'.tif')
            a=tom_norm(i.Value,1);
            imwrite(a',copyto,'Compression','none');%no compression
        elseif findstr(copyto,'.jpg')
            a=tom_norm(i.Value,1);
            imwrite(a',copyto,'Quality',50);%best quality 100
        elseif findstr(copyto,'.bmp')
            a=tom_norm(i.Value,1);
            imwrite(a',copyto);            
        elseif findstr(copyto,'.png')
            a=tom_norm(i.Value,1);
            imwrite(a',copyto,'String',filename,'BitDepth',8);%better quality 16    
        end
    end
else
    disp(['Can not convert this file: ',filename]);
end

% --- BUTTON CHANGE CURRENT DIRECTORY ---
function change_dir_Callback(hObject, eventdata, handles)
cd (handles.Path);
pwd
ls;


%******************************************************
%            fonction need by tom_embrowse
%******************************************************            

% ----------- Function disp_im -----------
function disp_im(in)%disp_im(in,parameter)
in_red=imresize(in,.1);
[meanv max min std]=tom_devinternal(in_red);
if (meanv-4*std)>=(meanv+4*std)
    imagesc(in');
else
    imagesc(in',[meanv-4*std meanv+4*std]);colormap gray;axis image;
end;
colormap gray;   
%if nargin==2
%    switch parameter
%        case 'fixed'
%            set(gca,'Units','pixels');
%            pp=get(gca,'Position');sf=size(in);            
%            set(gca,'Position',[pp(1) pp(2) sf(1) sf(2)]);
%        otherwise
%            axis image; axis ij; colormap gray; %nothing changed, as nargin=1
%    end
%elseif nargin==1
    axis image; axis ij; %colormap gray
%end  

% ----------- Function tom_devinternal -----------
function [a,b,c,d,e]=tom_devinternal(A);
[s1,s2,s3]=size(A);
a=sum(sum(sum(A)))/(s1*s2*s3);
b=max(max(max(A)));
c=min(min(min(A)));
d=std2(A);
e=d^2;

% ----------- Function load_listbox -----------
function load_listbox(dir_path,handles)
cd (dir_path);
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
handles.Path=pwd;
guidata(handles.figure1,handles);
set(handles.listbox1,'String',handles.file_names,...
	'Value',1);
set(handles.text1,'String',pwd);
cd (handles.InitialPath);




