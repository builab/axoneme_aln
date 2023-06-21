function varargout = tom_average2D(varargin)
% TOM_AVERAGE2D(VOLUME) is a tool for averaging 2D particles.  
%
%   Syntax: tom_average2D 
%
%   See also TOM_ALIG2D, TOM_HIST3D, TOM_BIN, TOM_DEV
%
%   Created: 11/11/03  William Del Net & Florian Beck
%   Last modification: 02/11/04 William Del Net 
%   
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom
% 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_average2D_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_average2D_OutputFcn, ...
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


% --- Executes just before tom_average2D is made visible.
function tom_average2D_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for tom_average2D
handles.output = hObject;
% Update handles structure
handles.Filename='';
handles.Option='';
handles.OriginalPath=pwd;
handles.Path='';
if size(varargin,1) <1 
pathname = uigetdir(pwd,'Select a folder');
    if isequal(pathname,0) 
        error('Cancel button pressed. No data loaded.');
        return; 
    end;
    handles.Path= pathname;
    
else
%    if size(varargin,2)==2
%        if findstr(varargin{2},'fixed')
%            handles.Option='fixed';
%            if findstr(varargin{2},'noinfo')
%                handles.Option='fixed noinfo';
%            end
%            pathname = uigetdir('Select a folder');
%            if isequal(pathname,0) 
%                error('Cancel button pressed. No data loaded.');
%                return; 
%            end;
%            handles.Path= pathname;            
%        else   
%            handles.Path=cell2mat(varargin(2));
%        end
%    elseif size(varargin,2)==3
%        handles.Path=cell2mat(varargin(2));
%        handles.Option=varargin{3};
%    end
end
clear varargin
cd(handles.Path);
d=dir;
dd=struct2cell(d);
file=dd(1,3:size(dd,2));
handles.List=file;
if size(handles.List,2)==1
    set(handles.XY_slider,'Visible','off');
    set(handles.text2,'Visible','off');
else
    set(handles.XY_slider,'Visible','on');   
    set(handles.text2,'Visible','on');   
    set(handles.XY_slider,'Min',1);%set slider
    set(handles.XY_slider,'Max',size(handles.List,2));
    dif=get(handles.XY_slider,'Max') - get(handles.XY_slider,'Min');
    set(handles.XY_slider,'SliderStep',[1/dif 5/dif]);
end
for i=1:size(handles.List,2)
    if tom_isemfile([handles.Path '\' handles.List{i}]); %if em_file
        set(handles.no_emfile,'Visible','off');
        tmp=tom_emreadc([handles.Path '\' handles.List{i}]);
        set(handles.XY_slider,'Value',i);
        handles.Filename=handles.List{i};
        set(handles.picture_name,'String',[handles.Path  '\' handles.Filename]);
        tmp.Value=double(tmp.Value);
        handles.Image=tmp;
        [h,n]=tom_hist3d(handles.Image.Value);%set histogram
        handles.DataScale=[n(1)  n(size(n,2))];
        set(handles.limit_down,'String',handles.DataScale(1));
        set(handles.limit_up,'String',handles.DataScale(2));
        h=200.*h./(100.*handles.Image.Header.Size(1).*handles.Image.Header.Size(2).*handles.Image.Header.Size(3));
        axes(handles.Histogram);bar(n,h);axis auto;
        axes(handles.XY_slice);
        if findstr(handles.Option,'fixed')
            display_real(hObject, eventdata, handles);    
        else
            imagesc(tmp.Value',[handles.DataScale]);
            set(handles.XY_slice,'Tag','XY_slice')
        end
        %h_im=findall(gcf,'Type','image');
        %set(h_im,'Tag','MainImage'); 
        set(get(handles.XY_slice,'Children'),'Tag','MainImage');
        colormap gray;
        dim_x=handles.Image.Header.Size(1);
        dim_y=handles.Image.Header.Size(2);
        handles.actualaxis=[1 dim_x 1 dim_y];
        break;
    else %not em_file
        tmp.Value=0;
        temp.Header=[];
        handles.Filename=handles.List{i};
        set(handles.picture_name,'String',[handles.Path '\' handles.Filename]);
        set(handles.no_emfile,'Visible','on');
        axes(handles.XY_slice);
        cla;%imshow(0);        
    end
end
handles.radius = 32;
handles.first_line=1;
for i=1:size(handles.List,2)
    mp(i).Filename=handles.List(i);
    mp(i).X=[];
    mp(i).Y=[];
    mp(i).Angle=[];
    mp(i).Pre_Angle=[];
    mp(i).refine_success=[];
end
handles.MarkerPoint=mp;
handles.ParticleNumber='yes';
handles.ref=[];
handles.MarkerPoint(1).NumberParticle=0;
cd (handles.OriginalPath);
set(handles.average2d,'Toolbar','figure');
handles.Markerfile_by_default=[handles.Path '\zMarkerfile_By_Default'];
guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = tom_average2D_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject,handles);

%***********************************************************
% --- MENU NEW ---
function menu_new_Callback(hObject, eventdata, handles)
handles.ref=[];
for i=1:size(handles.MarkerPoint,2)
    handles.MarkerPoint(i).X=[];
    handles.MarkerPoint(i).Y=[];
    handles.MarkerPoint(i).Angle=[];
    handles.MarkerPoint(i).Pre_Angle=[];
    handles.first_line=1;
end
handles.MarkerPoint(1).ref=[];
handles.MarkerPoint(1).NumberParticle=0;
axes(handles.part_click);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.part_aligned);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.part_ref);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.particle_mask);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.XY_slice);
%axes(handles.part_click);
if tom_isemfile([handles.Path '\' handles.Filename]); %if em_file
    set(handles.no_emfile,'Visible','off');
    [h,n]=tom_hist3d(handles.Image.Value);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];
    if findstr(handles.Option,'fixed')
        handles.Image=handles.Image;
        display_real(hObject, eventdata, handles);
    else
        imagesc(handles.Image.Value',[handles.DataScale]);
        set(handles.XY_slice,'Tag','XY_slice')
    end 
else
    tmp.Value=0;
    temp.Header=[];    
    set(handles.no_emfile,'Visible','on');
    cla;%imshow(0);           
end
set(get(handles.XY_slice,'Children'),'Tag','MainImage');
set(handles.number_part,'String',['Number of particles: ']);
RefreshImage_Callback(hObject, eventdata, handles);
set(handles.editradius,'Enable','on'); %unblock radius 
guidata(hObject,handles);

% --- MENU NEW DIRECTORY ---
function menu_newdir_Callback(hObject, eventdata, handles)
handles.ref=[];
for i=1:size(handles.MarkerPoint,2)
    handles.MarkerPoint(i).X=[];
    handles.MarkerPoint(i).Y=[];
    handles.MarkerPoint(i).Angle=[];
    handles.MarkerPoint(i).Pre_Angle=[];
end
handles.MarkerPoint(1).ref=[];
handles.MarkerPoint(1).NumberParticle=0;
axes(handles.part_click);
%[h,n]=tom_hist3d(handles.Image.Value);%range for handles.ref
%Scale=[n(1)  n(size(n,2))];
axes(handles.part_click);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.part_aligned);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.part_ref);
cla;%imshow(0);%imshow(0,[Scale]);
axes(handles.particle_mask);
cla;%imshow(0);%imshow(0,[Scale]);
set(handles.number_part,'String',['Number of particles: ']);
set(handles.refinement_change,'String','');
pathname = uigetdir(pwd,'Select a folder');
if isequal(pathname,0) 
    error('Cancel button pressed. No data loaded.');
    return; 
end;
handles.Path= pathname;
cd(handles.Path);
d=dir;
dd=struct2cell(d);
file=dd(1,3:size(dd,2));
handles.List=file;
if size(handles.List,2)==1
    set(handles.XY_slider,'Visible','off');
    set(handles.text2,'Visible','off');
else
    set(handles.XY_slider,'Visible','on');   
    set(handles.text2,'Visible','on');   
    set(handles.XY_slider,'Min',1);%set slider
    set(handles.XY_slider,'Max',size(handles.List,2));
    dif=get(handles.XY_slider,'Max') - get(handles.XY_slider,'Min');
    set(handles.XY_slider,'SliderStep',[1/dif 5/dif]);
end
for i=1:size(handles.List,2)
    if tom_isemfile([handles.Path '\' handles.List{i}]); %if em_file
        set(handles.no_emfile,'Visible','off');
        tmp=tom_emreadc([handles.Path '\' handles.List{i}]);
        set(handles.XY_slider,'Value',i);
        handles.Filename=handles.List{i};
        set(handles.picture_name,'String',[handles.Path  '\' handles.Filename]);
        tmp.Value=double(tmp.Value);
        handles.Image=tmp;
        [h,n]=tom_hist3d(handles.Image.Value);%set histogram
        handles.DataScale=[n(1)  n(size(n,2))];
        set(handles.limit_down,'String',handles.DataScale(1));
        set(handles.limit_up,'String',handles.DataScale(2));
        h=200.*h./(100.*handles.Image.Header.Size(1).*handles.Image.Header.Size(2).*handles.Image.Header.Size(3));
        axes(handles.Histogram);bar(n,h);axis auto;
        axes(handles.XY_slice);
        if findstr(handles.Option,'fixed')
            display_real(hObject, eventdata, handles);    
        else
            imagesc(tmp.Value',[handles.DataScale]);
            set(handles.XY_slice,'Tag','XY_slice')
        end
        colormap gray;
       
        dim_x=handles.Image.Header.Size(1);
        dim_y=handles.Image.Header.Size(2);
        handles.actualaxis=[1 dim_x 1 dim_y];
        break;
    else %not em_file
        tmp.Value=0;
        temp.Header=[];
        handles.Filename=handles.List{i};
        set(handles.picture_name,'String',[handles.Path '\' handles.Filename]);
        set(handles.no_emfile,'Visible','on');
        axes(handles.XY_slice);
        cla;%imshow(0);        
    end
end
handles.radius = 32;
handles.ParticleNumber='yes';
cd (handles.OriginalPath);
set(handles.average2d,'Toolbar','figure');
set(handles.refine,'Enable','off');
set(handles.power_search,'Enable','off');
guidata(hObject,handles);

% --- MENU LOAD MARKERPOINT ---
function load_mp_Callback(hObject, eventdata, handles)
cd (handles.Path);
[myname, mypathname] = uigetfile('*.mat', 'LOAD MARKERPOINT FILE');
myfile=[mypathname myname];
if myfile(1)~=0 & myfile(2)~=0 %myfile= 0 0 when 'cancel' is clicked
    load(myfile);
    handles.MarkerPoint=MarkerPoint;
    handles.ref=handles.MarkerPoint(1).ref;
    % check for existance to be comptible to older versions
    q=fieldnames(handles.MarkerPoint(1));
    flag=0;
        for lauf=1:size(q,1)
            if (strcmp(char(q(lauf)),'ref_radius')==1)
                flag=1;
            end;
        end;
    if (flag==1)
         handles.radius=handles.MarkerPoint(1).ref_radius;
    else
         handles.radius=32;
    end;
    set(handles.editradius,'String',num2str(handles.radius));
    
    set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
    
    if handles.MarkerPoint(1).NumberParticle==0
        set(handles.editradius,'Enable','on');
    else
        set(handles.editradius,'Enable','off');
    end        
    axes(handles.XY_slice);            
    if findstr(handles.Option,'fixed')
        handles.Image=handles.Image;
        display_real(hObject, eventdata, handles);
    else
        imagesc(handles.Image.Value',[handles.DataScale]);
        set(handles.XY_slice,'Tag','XY_slice');
    end 
   
    RefreshImage_Callback(hObject, eventdata, handles);
    axes(handles.part_ref);
    [h,n]=tom_hist3d(handles.ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];   
    a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
    guidata(hObject,handles);
end
cd (handles.OriginalPath);

% --- MENU SAVE MARKERPOINT ---
function save_mp_Callback(hObject, eventdata, handles)
cd (handles.Path);
[myname, mypathname] = uiputfile('*.mat', 'SAVE YOUR MARKERPOINT FILE AS');
myfile=[mypathname myname];
if myfile(1)~=0 & myfile(2)~=0 %myfile= 0 0 when 'cancel' is clicked
    if isempty(findstr(myfile,'.mat'))
        myfile=strcat(myfile,'.mat');
    end
    handles.MarkerPoint(1).ref=handles.ref;
    handles.MarkerPoint(1).ref_radius=handles.radius;
    MarkerPoint=handles.MarkerPoint;
    save(myfile,'MarkerPoint');
end
cd (handles.OriginalPath);

% --- MENU LOAD AVERAGE ---
function load_ref_Callback(hObject, eventdata, handles)
cd (handles.Path);
[myname, mypathname] = uigetfile('*.em', 'LOAD MARKERPOINT FILE');
myfile=[mypathname myname];
if myfile(1)~=0 & myfile(2)~=0 %myfile= 0 0 when 'cancel' is clicked
    handles.ref=tom_emread(myfile);handles.ref=handles.ref.Value;
    axes(handles.part_ref);
    [h,n]=tom_hist3d(handles.ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];
    a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);   
    guidata(hObject,handles);
end
cd (handles.OriginalPath);

% --- MENU SAVE AVERAGE ---
function save_ref_Callback(hObject, eventdata, handles)
cd (handles.Path);
[myname, mypathname] = uiputfile('*.em', 'SAVE YOUR AVERAGE PICTURE AS');
myfile=[mypathname myname];
if myfile(1)~=0 & myfile(2)~=0 %myfile= 0 0 when 'cancel' is clicked
    if isempty(findstr(myfile,'.em'))
        myfile=strcat(myfile,'.em');
    end
    tom_emwrite(myfile,handles.ref);
end
cd (handles.OriginalPath);

% --- BUTTON SET HISTOGRAM ---
function sethistogram_Callback(hObject, eventdata, handles)
axes(handles.Histogram);
k = waitforbuttonpress;
     point1 = get(gca,'CurrentPoint');    % button down detected
     finalRect = rbbox;                   % return figure units
     point2 = get(gca,'CurrentPoint');    % button up detected
     point1 = point1(1,1:2);              % extract x and y
     point2 = point2(1,1:2);
     p1 = min(point1,point2);             % calculate locations
     offset = abs(point1-point2);         % and dimensions
     x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
     %y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
     %hold on;
     %axis manual;    
handles.DataScale=[x(1) x(2)];
set(handles.limit_down,'String',handles.DataScale(1));
set(handles.limit_up,'String',handles.DataScale(2));
guidata(hObject,handles);
set(handles.Histogram,'Xlim',[x(1) x(2)]);
UPDATE_ALL_Callback(hObject, eventdata, handles);
%set(handles.Histogram,'Tag','Histogram');
RefreshImage_Callback(hObject, eventdata, handles);

% --- BUTTON RESET HISTOGRAM ---
function updatehistogram_Callback(hObject, eventdata, handles)
axes(handles.Histogram);
%[h,n]=tom_hist3d(handles.Image.Value);
[h,n]=tom_hist3d(tom_bin(handles.Image.Value,2));%set histogram, binned 2
handles.DataScale=[n(1)  n(size(n,2))];
set(handles.limit_down,'String',handles.DataScale(1));
set(handles.limit_up,'String',handles.DataScale(2));
h=200.*h./(100.*handles.Image.Header.Size(1).*handles.Image.Header.Size(2).*handles.Image.Header.Size(3));
bar(n,h);axis auto;
guidata(hObject,handles);
UPDATE_ALL_Callback(hObject, eventdata, handles);
set(handles.Histogram,'Tag','Histogram');
RefreshImage_Callback(hObject, eventdata, handles);

% --- BUTTON SET MANUALLY HISTOGRAM ---
function setmanual_histogram_Callback(hObject, eventdata, handles)
%tmp_obj=findobj('Tag','Histogram');%Histogram
min=str2num(get(handles.limit_down,'String'));
max=str2num(get(handles.limit_up,'String'));
handles.DataScale=[min max];
guidata(hObject,handles);
%set(tmp_obj,'Xlim',[min max]);
set(handles.Histogram,'Xlim',[min max]);
UPDATE_ALL_Callback(hObject, eventdata, handles);
RefreshImage_Callback(hObject, eventdata, handles);

% --- EDIT BOX LIMIT MIN ---
function limit_down_Callback(hObject, eventdata, handles)

% --- EDIT BOX LIMIT MAX ---
function limit_up_Callback(hObject, eventdata, handles)

% --- BUTTON ZOOM IN ---
function zoom_in_Callback(hObject, eventdata, handles)
axes(handles.XY_slice);
k = waitforbuttonpress;
     point1 = get(gca,'CurrentPoint');    % button down detected
     finalRect = rbbox;                   % return figure units
     point2 = get(gca,'CurrentPoint');    % button up detected
     point1 = point1(1,1:2);              % extract x and y
     point2 = point2(1,1:2);
     p1 = min(point1,point2);             % calculate locations
     offset = abs(point1-point2);         % and dimensions
     x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
     y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
x=round(x);
y=round(y);
handles.actualaxis=[x(1) x(2) y(1) y(3)];
axis([x(1) x(2) y(1) y(3)]);
guidata(hObject,handles);
%RefreshImage_Callback(hObject, eventdata, handles);

% --- BUTTON ZOOM RESET ---
function zoom_reset_Callback(hObject, eventdata, handles)
axes(handles.XY_slice);
dim_z=handles.Image.Header.Size(3);
dim_x=handles.Image.Header.Size(1);
dim_y=handles.Image.Header.Size(2);
axes(handles.XY_slice);
set(handles.XY_slice,'Tag','XY_slice');
handles.actualaxis=[1 dim_x 1 dim_y];
axis([1 dim_x 1 dim_y]);
guidata(hObject,handles);
%RefreshImage_Callback(hObject, eventdata, handles);

% --- BUTTON PICK ---
function pickit_Callback(hObject, eventdata, handles)
AllButtonEnable('off');
set(handles.stop,'Visible','on');
m=handles.output;
set(m,'Pointer','crosshair');
set(findobj(0,'Tag','MainImage'),'ButtonDownFcn','tom_average2d(''MouseDown_Image'',gcbo)');
guidata(hObject,handles);

% --- BUTTON STOP ---
function stop_Callback(hObject, eventdata, handles)
AllButtonEnable('on');
set(handles.stop,'Visible','off');
m=handles.output;
set(m,'Pointer','arrow');
ClearButtonDownFcn;

% --- BUTTON DELETE MARK ---
function delete_Callback(hObject, eventdata, handles)
uiwait(msgbox('Please, select the marker you want to delete','Delete marker','help'));
[Xz,Yz]=ginput(1);
ii=get(handles.XY_slider,'Value');
axes(handles.XY_slice);
Nbm=size(handles.MarkerPoint(ii).X,2);
for i=1:Nbm
    D=sqrt((handles.MarkerPoint(ii).X(i)-Xz).^2 + (handles.MarkerPoint(ii).Y(i)-Yz).^2);
    if D<=5        
        x=handles.MarkerPoint(ii).X(i);y=handles.MarkerPoint(ii).Y(i);
        Rad = 20;     
        uu = [x x x x-Rad x+Rad];vv = [y-Rad y+Rad y y y];        
        line(uu,vv,'LineWidth',2,'Color',[0 1 0]);%[1 0 0]red dark
        switch handles.ParticleNumber
            case 'yes'
                text(x+5,y+10,num2str(i),'FontWeight','bold','Color',[0 1 0],'Fontsize',20);%[1 0 0]red dark                
        end                
        message=['Do you really want to delete the Current marker in red or All of them?'];
        asd=0;
        Question=questdlg(message,'Delete marker','Current','All','No','Current');
        if strcmp(Question,'Current') 
            handles.MarkerPoint(ii).X(i)=[];
            handles.MarkerPoint(ii).Y(i)=[];
            handles.MarkerPoint(ii).Angle(i)=[];
            handles.MarkerPoint(ii).Pre_Angle(i)=[];
            handles.MarkerPoint(ii).refine_success(i)=[];
            if findstr(handles.Option,'fixed')
                handles.Image=handles.Image;
                display_real(hObject, eventdata, handles);
            else
                imagesc(handles.Image.Value',[handles.DataScale]);
                set(handles.XY_slice,'Tag','XY_slice');
            end            
            radius=str2num(get(handles.editradius,'String'));
            part_box=handles.Image.Value(round(x-(2*radius)):round(x+(2*radius-1)),round(y-(2*radius)):round(y+(2*radius-1)));
            [trans,rot,delta,moved_part]=tom_align2d(part_box,handles.ref,radius*2,5,10);
            handles.MarkerPoint(1).NumberParticle=handles.MarkerPoint(1).NumberParticle-1;
            set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
            moved_part_norm=(moved_part-mean2(moved_part))./abs(mean2(moved_part)); 
            handles.ref=handles.ref-moved_part_norm;
            axes(handles.part_ref);
            [h,n]=tom_hist3d(handles.ref);%range for handles.ref
            Scale=[n(1)  n(size(n,2))];
            a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
            b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
            RefreshImage_Callback(hObject, eventdata, handles);
            if handles.MarkerPoint(1).NumberParticle==0 %Block radius if there is 1 marker
                axes(handles.part_click);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.part_aligned);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.part_ref);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.particle_mask);
                cla;%imshow(0,[handles.DataScale]);                
                handles.ref=[];                
                set(handles.editradius,'Enable','on');
            else
                set(handles.editradius,'Enable','off');
            end
            guidata(hObject,handles);
        elseif strcmp(Question,'All')
            message=['Are you sure you want to delete all markers number ?'];
            Question2=questdlg(message,'Delete marker','Yes','No','No');
            if strcmp(Question2,'Yes')
                for i=1:size(handles.List,2)
                    for j=1:size(handles.MarkerPoint(i).X,2)
                        handles.MarkerPoint(j).X=[];
                        handles.MarkerPoint(j).Y=[];
                        handles.MarkerPoint(j).Angle=[];
                        handles.MarkerPoint(j).Pre_Angle=[];
                        handles.MarkerPoint(j).refine_success=[];
                    end
                end
                if findstr(handles.Option,'fixed')
                    handles.Image=handles.Image;
                    display_real(hObject, eventdata, handles);
                else
                    imagesc(handles.Image.Value',[handles.DataScale]);
                    
                end 
                axes(handles.part_click);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.part_aligned);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.part_ref);
                cla;%imshow(0,[handles.DataScale]);
                axes(handles.particle_mask);
                cla;%imshow(0,[handles.DataScale]);                
                handles.ref=[];
                handles.MarkerPoint(1).NumberParticle=0;
                set(handles.editradius,'Enable','on');                
                set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
            else
                if findstr(handles.Option,'fixed')
                    handles.Image=handles.Image;
                    display_real(hObject, eventdata, handles);
                else
                    imagesc(handles.Image.Value',[handles.DataScale]);                    
                end                                       
                RefreshImage_Callback(hObject, eventdata, handles);                
            end
        else
            if findstr(handles.Option,'fixed')
                handles.Image=handles.Image;
                display_real(hObject, eventdata, handles);
            else
                imagesc(handles.Image.Value',[handles.DataScale]);
            end                       
            RefreshImage_Callback(hObject, eventdata, handles);            
        end 
        break;
    end
end
guidata(hObject,handles);

% --- BUTTON REFINE MARK ---
function refine_Callback(hObject, eventdata, handles)
handles.refinement_steps=str2num(get(handles.refinement_iterations,'String'));
m=findobj('tag','editradius');
fine_align_parameter(1)=str2num(get(m,'String'));
fine_align_parameter(2)=str2num(get(handles.iteration,'String'));
%m=findobj('tag','angle');
m=handles.angle;
fine_align_parameter(3)=str2num(get(m,'String'));
m=findobj('tag','transx');
fine_align_parameter(4)=str2num(get(m,'String'));
m=findobj('tag','transy');
fine_align_parameter(5)=str2num(get(m,'String'));
handles.refinement_steps=str2num(get(handles.refinement_iterations,'String'));
fine_align_parameter(6)=round((fine_align_parameter(4)+fine_align_parameter(5))/2) + 3; 
% 3 is hardcoded because it is only the intern threshold of tom_align_2d  
if (get(handles.filter_avg_apply_filter,'Value')==1)
    ref_in=handles.filt_ref;
else
    ref_in=handles.ref;
end;
for i=1:handles.refinement_steps % ... refine n times 
    ref_in=handles.ref;
    [new_MarkerPoint,new_ref,num_not_aliged_part]=tom_refine_avg(ref_in,handles.MarkerPoint,fine_align_parameter,handles);
    change=sqrt(sum(sum((handles.ref-new_ref).^2)));
    s_change(i)=change;
    handles.ref=new_ref;
    handles.MarkerPoint=new_MarkerPoint;
    save s_change2;
    % update gui
    set(handles.refinement_change,'String',num2str(change));
    guidata(hObject,handles);
    axes(handles.part_ref);
    [h,n]=tom_hist3d(new_ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];    
    a=imagesc(new_ref',[Scale]);%imshow(new_ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);    
    if change<=0.1
        break;
    end
end;
% plot refinement graph
if (handles.refinement_steps > 2)
    hf=figure; plot(s_change);
    set(hf,'name','refinement progress');
end;
RefreshImage_Callback(hObject, eventdata, handles);
if (num_not_aliged_part>0)
    message=['From ' num2str(handles.MarkerPoint(1).NumberParticle) ' particles clicked,  ' num2str(num_not_aliged_part) ... 
            ' could not be aligned. Do you want to delete the not aligned particle?'];       
    Question=questdlg(message,'Delete marker','Yes','No','No');
    deleted=0;
    if (strcmp(Question,'Yes'))
        for i=1:size(handles.MarkerPoint,2)
            for j=1:(size(handles.MarkerPoint(i).X,2))
                if (j>size(handles.MarkerPoint(i).X,2))
                    break; %additioal break because matlab hates dynamic loops
                end;                
                if (handles.MarkerPoint(i).refine_success(j)==0)
                    handles.MarkerPoint(i).X(j)=[];
                    handles.MarkerPoint(i).Y(j)=[];
                    handles.MarkerPoint(i).Angle(j)=[];
                    handles.MarkerPoint(j).Pre_Angle(j)=[];
                    handles.MarkerPoint(i).refine_success(j)=[];
                    handles.MarkerPoint(1).NumberParticle=handles.MarkerPoint(1).NumberParticle-1;
                    j=1;  
                end;    
            end;
        end;
        set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
        imagesc(handles.Image.Value',[handles.DataScale]);
        guidata(hObject,handles);
        RefreshImage_Callback(hObject, eventdata, handles);
    end;
end;


% --- EDIT REFINE ---
function refinement_iterations_Callback(hObject, eventdata, handles)
handles.refinement_steps=str2num(get(handles.refinement_iterations,'String'));
guidata(hObject,handles);

% --- BUTTON POWER SEARCH ---
function power_search_Callback(hObject, eventdata, handles)
myfile=[handles.Path '\reference'];
myref=handles.ref;
save(myfile,'myref');
set(handles.average2d,'UserData',handles);
x=get(handles.average2d,'UserData');
if (get(handles.filter_avg_apply_filter,'Value')==1)
    x.ref=handles.filt_ref;
end;
set(handles.average2d,'UserData',x);
guidata(hObject,handles);
%mp=tom_find_particle_parameters(hObject, eventdata, handles);
mp=tom_find_particle_parameters;%handles.MarkerPoint=tom_find_particle_parameters(hObject, eventdata, handles);
if ~isempty(mp)
    handles.MarkerPoint=mp;
    handles.ref=handles.MarkerPoint(1).ref;
    set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
    if handles.MarkerPoint(1).NumberParticle==0
        set(handles.editradius,'Enable','on');
    else
        set(handles.editradius,'Enable','off');
    end        
    axes(handles.XY_slice);            
    if findstr(handles.Option,'fixed')
        handles.Image=handles.Image;
        display_real(hObject, eventdata, handles);
    else
        imagesc(handles.Image.Value',[handles.DataScale]);
        set(handles.XY_slice,'Tag','XY_slice');
    end      
    RefreshImage_Callback(hObject, eventdata, handles);
    axes(handles.part_ref);
    [h,n]=tom_hist3d(handles.ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];   
    a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);        
end
m=findobj('Tag','Adjust_search_param');
delete(m);
guidata(hObject,handles);


% --- PARTICLES'S NUMBER ---
function checkbox1_Callback(hObject, eventdata, handles)
axes(handles.XY_slice);
a=get(handles.checkbox1,'Value');
if a==0;
    handles.ParticleNumber='no';
else;
    handles.ParticleNumber='yes';
end
guidata(hObject,handles);
if findstr(handles.Option,'fixed')
    handles.Image=handles.Image;
    display_real(hObject, eventdata, handles);
else
    imagesc(handles.Image.Value',[handles.DataScale]);
end
set(get(handles.XY_slice,'Children'),'Tag','MainImage');
%imagesc(handles.Image',[handles.DataScale]);%set(gcf,'DoubleBuffer','on');
RefreshImage_Callback(hObject, eventdata, handles);

% --- RADIUS ---
function editradius_Callback(hObject, eventdata, handles)
handles.radius = round(str2double(get(handles.editradius,'String')));
%handles.MarkerPoint(4,:,:)=handles.radius;
guidata(hObject,handles);


% --- SLIDER SCAN FOLDER ---
function XY_slider_Callback(hObject, eventdata, handles)
index=round(get(handles.XY_slider,'Value'));
%set(handles.picture_name,'String',[handles.Path '\' handles.List{index}]);
if tom_isemfile([handles.Path '\' handles.List{index}])==1;
    set(handles.no_emfile,'Visible','off');
    handles.Filename=handles.List{index};
    tmp=tom_emreadc([handles.Path '/' handles.Filename]);tmp.Value=double(tmp.Value);
    set(handles.picture_name,'String',[handles.Path '\' handles.Filename]);
else
    tmp.Value=0;
    temp.Header=[];
    set(handles.picture_name,'String',[handles.Path '\' handles.List{index}]);
    set(handles.no_emfile,'Visible','on');
    cla;%imshow(0);
    return;%break;
end
handles.Image=tmp;
[h,n]=tom_hist3d(tom_bin(handles.Image.Value,2));%set histogram, binned 2
handles.DataScale=[n(1)  n(size(n,2))];
set(handles.limit_down,'String',handles.DataScale(1));
set(handles.limit_up,'String',handles.DataScale(2));
h=200.*h./(100.*handles.Image.Header.Size(1).*handles.Image.Header.Size(2).*handles.Image.Header.Size(3));
axes(handles.Histogram);
cla;%imshow(0,[handles.DataScale]);
bar(n,h);axis auto;
axes(handles.XY_slice);
if findstr(handles.Option,'fixed')
    display_real(hObject, eventdata, handles);    
else
    imagesc(tmp.Value',[handles.DataScale]);
    set(handles.XY_slice,'Tag','XY_slice');
end
set(get(handles.XY_slice,'Children'),'Tag','MainImage');
colormap gray;
RefreshImage_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

% --- EDIT ROTATE PARTICLE AVERAGE ---
function rotate_avg_angle_Callback(hObject, eventdata, handles)
rotation=str2num(get(handles.rotate_avg_angle,'String'));
%disp(rotation);
orig_sizeX=size(handles.ref,1);
orig_sizeY=size(handles.ref,1);
new_size=(size(handles.ref,1)*2)+(size(handles.ref,2)*2);
area=ones(new_size,new_size);
mean=tom_dev(handles.ref,'on');
area=area*mean;
area(((new_size/2)-(orig_sizeX/2)):((new_size/2-1)+(orig_sizeX/2)), ...
((new_size/2)-(orig_sizeY/2)):((new_size/2-1)+(orig_sizeY/2)))=handles.ref((1:orig_sizeX),(1:orig_sizeY));
area_rot=imrotate(area,-rotation,'bilinear','crop');
handles.ref=area_rot(((new_size/2)-(orig_sizeX/2)):((new_size/2-1)+(orig_sizeX/2)), ...
((new_size/2)-(orig_sizeY/2)):((new_size/2-1)+(orig_sizeY/2)));
axes(handles.part_ref);
[h,n]=tom_hist3d(handles.ref);%range for handles.ref
Scale=[n(1)  n(size(n,2))];
a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
guidata(hObject,handles);

% --- EDIT FILTER AVERAGE - LIMITE LOW ---
function filter_avg_low_Callback(hObject, eventdata, handles)
hi=str2num(get(handles.filter_avg_hi,'String'));
low=str2num(get(handles.filter_avg_low,'String'));
if (get(handles.filter_avg_apply_filter,'Value')==1)
    handles.filt_ref=tom_bandpass(handles.ref,low,hi);
    axes(handles.particle_mask);
    [h,n]=tom_hist3d(handles.filt_ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];    
    a=imagesc(handles.filt_ref',[Scale]);%imshow(handles.filt_ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);            
    guidata(hObject,handles);
end;

% --- EDIT FILTER AVERAGE - LIMITE HIGHT ---
function filter_avg_hi_Callback(hObject, eventdata, handles)
hi=str2num(get(handles.filter_avg_hi,'String'));
low=str2num(get(handles.filter_avg_low,'String'));
if (get(handles.filter_avg_apply_filter,'Value')==1)
    handles.filt_ref=tom_bandpass(handles.ref,low,hi);
    axes(handles.particle_mask);
    [h,n]=tom_hist3d(handles.filt_ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];
    a=imagesc(handles.filt_ref',[Scale]);%imshow(handles.filt_ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);                
    guidata(hObject,handles);
end;

% --- CHECK BOX APPLY FILTER ---
function filter_avg_apply_filter_Callback(hObject, eventdata, handles)
hi=str2num(get(handles.filter_avg_hi,'String'));
low=str2num(get(handles.filter_avg_low,'String'));
if (get(handles.filter_avg_apply_filter,'Value')==1)
    handles.filt_ref=tom_bandpass(handles.ref,low,hi);
    axes(handles.particle_mask);
    [h,n]=tom_hist3d(handles.filt_ref);%range for handles.ref
    Scale=[n(1)  n(size(n,2))];
    a=imagesc(handles.filt_ref',[Scale]);%imshow(handles.filt_ref',[Scale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);                
    guidata(hObject,handles);
end;



%********************************************************************
%*****   Other function  ********************************************
%********************************************************************
function UPDATE_ALL_Callback(hObject, eventdata, handles)
dim_x=handles.Image.Header.Size(1);
dim_y=handles.Image.Header.Size(2);
dim_z=handles.Image.Header.Size(3);
tmp=tom_emreadc([handles.Path '/' handles.Filename]);tmp.Value=double(tmp.Value);
tmp=tmp.Value;
tmp=mean(tmp,3);
axes(handles.XY_slice);
if findstr(handles.Option,'fixed')
    handles.Image=tmp;
    display_real(hObject, eventdata, handles);    
else
    imagesc(tmp',[handles.DataScale]);
    set(handles.XY_slice,'Tag','XY_slice');
end
set(get(handles.XY_slice,'Children'),'Tag','MainImage');
axis(handles.actualaxis);
colormap gray;

%*****   REFRESH IMAGE  *****
function RefreshImage_Callback(hObject, eventdata, handles)
ii=get(handles.XY_slider,'Value');
ii=round(ii);
set(handles.XY_slider,'Value',ii);
axes(handles.XY_slice);
for i=1:size(handles.MarkerPoint(ii).X,2)
    x=handles.MarkerPoint(ii).X(i);
    y=handles.MarkerPoint(ii).Y(i);
    Rad = 20;
    uu = [x x x x-Rad x+Rad];
    vv = [y-Rad y+Rad y y y];
    if (handles.MarkerPoint(ii).refine_success(i)==1)
        line(uu,vv,'LineWidth',2,'color',[1 0 0]);%[1 0.75 0]orange
    else
        line(uu,vv,'LineWidth',2,'color',[0 0 1]);%[1 0.75 0]orange
    end;
    switch handles.ParticleNumber
        case 'yes'
            if (handles.MarkerPoint(ii).refine_success(i)==1)
                text(x+5,y+10,num2str(i),'FontWeight','bold','Color',[1 0 0],'Fontsize',20);%[1 0.75 0]orange
            else
                text(x+5,y+10,num2str(i),'FontWeight','bold','Color',[0 0 1],'Fontsize',20);
            end;
    end
end


% --- Display the image with 'fixed'option ---
function display_real(hObject, eventdata, handles);
in=handles.Image';
in_red=imresize(in,.25);
imagesc(in,[handles.DataScale]);
colormap gray(256);
param1='';param2='';
if findstr(handles.Option,'fixed')
    param1='fixed';
end
if findstr(handles.Option,'noinfo')
    param2='noinfo';
end
switch param1        
     case 'fixed'
        set(gca,'Units','pixels');
        pp=get(gca,'Position');sf=size(in);            
        set(gca,'Position',[pp(1) pp(2) sf(1) sf(2)]);
        if isempty(param2)
            t=title(['Info: (' num2str(size(in)) ') pixel']); %, mean:' num2str(meanv,3) ' std:' num2str(std,3)
        end
    otherwise
        axis image; axis ij; %colormap gray; %nothing changed, as nargin=1
        if isempty(param2)
            %t=title(['Info: (' num2str(size(in)) ') pixel, mean:' num2str(meanv,3) ' std:' num2str(std,3) ]);
            t=title(['Info: (' num2str(size(in)) ') pixel']);
        end
end

% ----------- MouseDown_Image -----------
function MouseDown_Image(hObject)
%(hObject, eventdata, handles)
%---- Called by ButtonDownFcn on XY_slice ----
%This function is used to put markers.
%It is called just after a click on XY_slice
h_ave=findobj(0,'Tag','average2d');handles=guidata(h_ave);
point1 = get(gca,'CurrentPoint');    % button down detected
pt = round(point1(1,1:2));
Rad = 20;
x=pt(1);y=pt(2);
uu = [x x x x-Rad x+Rad];
vv = [y-Rad y+Rad y y y];
handles.h_line=line(uu,vv,'LineWidth',2,'color',[1 0 0]); %[1 0.75 0]orange
ii=get(handles.XY_slider,'Value');
if (handles.first_line==1)
    handles.MarkerPoint(ii).Pre_Angle(1)=0;
end;

handles.first_line=0;

handles.MarkerPoint(ii).X=[handles.MarkerPoint(ii).X x];
handles.MarkerPoint(ii).Y=[handles.MarkerPoint(ii).Y y];
handles.MarkerPoint(ii).Angle=[handles.MarkerPoint(ii).Angle 0];


handles.MarkerPoint(ii).refine_success=[handles.MarkerPoint(ii).refine_success 1];
set(handles.editradius,'Enable','off'); %block radius after 1 marker
switch handles.ParticleNumber
    case 'yes'
        text(x+5,y+10,num2str(size(handles.MarkerPoint(ii).X,2)),'FontWeight','bold','Color',[1 0 0],'Fontsize',20);%[1 0.75 0]orange
end
radius=str2num(get(handles.editradius,'String'));
if isempty(handles.ref)%size(handles.MarkerPoint(ii).X,2)==1
    handles.ref=handles.Image.Value(round(x-radius+1):round(x+radius),round(y-radius+1):round(y+radius));
    handles.ref=(handles.ref-mean2(handles.ref))./mean2(handles.ref);
    [h,n]=tom_hist3d(handles.ref);%set histogram
    DataScale_first=[n(1)  n(size(n,2))];
    handles.MarkerPoint(1).NumberParticle=handles.MarkerPoint(1).NumberParticle+1;
    set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
    axes(handles.part_click)
    a=imagesc(handles.ref',[DataScale_first]);%imagesc(handles.ref',[handles.DataScale]);
    set(a,'Tag','part_click');
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
    %imshow(handles.ref',[DataScale_first]);
    axes(handles.part_aligned)
    a=imagesc(handles.ref',[DataScale_first]);
    set(a,'Tag','part_aligned');
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
    %imshow(handles.ref',[DataScale_first]);
    axes(handles.part_ref)
    a=imagesc(handles.ref',[DataScale_first]);
    set(a,'Tag','handles.part_ref');
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
    %imshow(handles.ref',[DataScale_first]);
else
    if ((x-(2*radius))<1|(y-(2*radius))<1|(x+(2*radius-1))>=size(handles.Image.Value,1)|(y+(2*radius-1))>=size(handles.Image.Value,2))%exceed size of picture
        i=size(handles.MarkerPoint(ii).X,2);
        message=['ERROR!!!   This particle number n° ' num2str(i) '  is too close to the border.        Please, select an another one.'];
        uiwait(msgbox(message,'Error','error'));
        handles.MarkerPoint(ii).X(i)=[];
        handles.MarkerPoint(ii).Y(i)=[];
        handles.MarkerPoint(ii).Angle(i)=[];
         handles.MarkerPoint.Pre_Angle(i)=[];
        handles.MarkerPoint(ii).refine_success(i)=[];
        axes(handles.XY_slice);
        if findstr(handles.Option,'fixed')
           % handles.Image=handles.Image;
            display_real(hObject, eventdata, handles);
        else
            imagesc(handles.Image.Value',[handles.DataScale]);
            set(handles.XY_slice,'Tag','XY_slice');
        end       
        RefreshImage_Callback(hObject, [], handles);
        SetButtonDownFcn;
        guidata(h_ave,handles);
        return;
    end
    data_image=handles.Image.Value(round(x-radius):round(x+radius-1),round(y-radius):round(y+radius-1));
    axes(handles.part_click)
    %imshow(data_image',[handles.DataScale]);
    a=imagesc(data_image',[handles.DataScale]);
    set(a,'Tag','handles.part_ref');
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);

    
    part_box=handles.Image.Value(round(x-(2*radius)):round(x+(2*radius-1)),round(y-(2*radius)):round(y+(2*radius-1)));
    iter=str2num(get(handles.iteration,'String'));
    if (get(handles.filter_avg_apply_filter,'Value')==1)
        ref_in=handles.filt_ref;
    else
        ref_in=handles.ref;
    end;
    [trans,rot,delta,moved_part]=tom_align2d(part_box,ref_in,radius*2,5,iter);
    handles.MarkerPoint(ii).Pre_Angle=[handles.MarkerPoint(ii).Pre_Angle rot];
    disp('insert A');
    i_max=size(handles.MarkerPoint(ii).X,2);
    uu = [handles.MarkerPoint(ii).X(i_max) handles.MarkerPoint(ii).X(i_max) handles.MarkerPoint(ii).X(i_max) handles.MarkerPoint(ii).X(i_max)-Rad handles.MarkerPoint(ii).X(i_max)+Rad];
    vv = [handles.MarkerPoint(ii).Y(i_max)-Rad handles.MarkerPoint(ii).Y(i_max)+Rad handles.MarkerPoint(ii).Y(i_max) handles.MarkerPoint(ii).Y(i_max) handles.MarkerPoint(ii).Y(i_max)];
    set(handles.h_line,'XData',uu,'LineWidth',2,'color',[1 0 0]);
    set(handles.h_line,'YData',vv,'LineWidth',2,'color',[1 0 0]);
    %axes(handles.part_aligned)
    set(gcf,'CurrentAxes',handles.part_aligned)
    %newplot(handles.part_aligned);
    cla;
    a=imagesc(moved_part',[handles.DataScale]);
    b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
    if (abs(delta(1))>str2num(get(handles.angle,'String'))|abs(delta(2))>str2num(get(handles.transx,'String'))|abs(delta(3))>str2num(get(handles.transy,'String')))
        message=['This particle couldn''t be aligned. Do you want to add it anyway?'];
        Question=questdlg(message,'Alignment problem','Yes','No','No');
        if strcmp(Question,'Yes')
            moved_part_norm=(moved_part-mean2(moved_part))./abs(mean2(moved_part));
            handles.ref=handles.ref+moved_part_norm;
            handles.MarkerPoint(1).NumberParticle=handles.MarkerPoint(1).NumberParticle+1;
            % display particle avg
            set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
            axes(handles.part_ref);
            [h,n]=tom_hist3d(handles.ref);%range for handles.ref
            Scale=[n(1)  n(size(n,2))];
            a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
            b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
            % display Filtered particle avg
            if (get(handles.filter_avg_apply_filter,'Value')==1)
                hi=str2num(get(handles.filter_avg_hi,'String'));
                low=str2num(get(handles.filter_avg_low,'String'));
                handles.filt_ref=tom_bandpass(handles.ref,low,hi);
                axes(handles.particle_mask);
                [h,n]=tom_hist3d(handles.filt_ref);%range for handles.filt_ref
                Scale=[n(1)  n(size(n,2))];                
                a=imagesc(handles.filt_ref',[Scale]);%imshow(handles.filt_ref',[Scale]);
                b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);                 
            end;
        else
            i=size(handles.MarkerPoint(ii).X,2);
            handles.MarkerPoint(ii).X(i)=[];
            handles.MarkerPoint(ii).Y(i)=[];
            handles.MarkerPoint(ii).Angle(i)=[];
            handles.MarkerPoint(ii).Pre_Angle(i)=[];
            handles.MarkerPoint(ii).refine_success(i)=[];
            axes(handles.XY_slice);
            if findstr(handles.Option,'fixed')
                handles.Image=handles.Image;
                display_real(hObject, eventdata, handles);
            else
                imagesc(handles.Image.Value',[handles.DataScale]);
                set(handles.XY_slice,'Tag','XY_slice');
            end
            RefreshImage_Callback(hObject, [], handles);
            SetButtonDownFcn;
        end
    else
        handles.MarkerPoint(1).NumberParticle=handles.MarkerPoint(1).NumberParticle+1;
        set(handles.number_part,'String',['Number of particles: ' num2str(handles.MarkerPoint(1).NumberParticle)]);
        moved_part_norm=(moved_part-mean2(moved_part))./abs(mean2(moved_part));
        handles.ref=handles.ref+moved_part_norm;
        axes(handles.part_ref);
        [h,n]=tom_hist3d(handles.ref);%range for handles.ref
        Scale=[n(1)  n(size(n,2))];       
        a=imagesc(handles.ref',[Scale]);%imshow(handles.ref',[Scale]);
        b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
        % display Filtered particle avg
        if (get(handles.filter_avg_apply_filter,'Value')==1)
            hi=str2num(get(handles.filter_avg_hi,'String'));
            low=str2num(get(handles.filter_avg_low,'String'));
            handles.filt_ref=tom_bandpass(handles.ref,low,hi);
            axes(handles.particle_mask);
            [h,n]=tom_hist3d(handles.filt_ref);%range for handles.filt_ref
            Scale=[n(1)  n(size(n,2))];            
            a=imagesc(handles.filt_ref',[Scale]);%imshow(handles.filt_ref',[Scale]);
            b=get(a,'Parent');set(b,'YTick',[],'XTick',[]);
        end;
    end
end
guidata(h_ave,handles);
% ----------- AllButtonEnable -----------
function AllButtonEnable(Status)
%set the properties Enable of all Button (except Stop button)
%to on or off
h_ave=findobj(0,'Tag','average2d');handles=guidata(h_ave);
set(handles.sethistogram,'Enable',Status);%button set histogram
set(handles.setmanual_histogram,'Enable',Status);%button set manually histogram
set(handles.updatehistogram,'Enable',Status);%button reset histogram
set(handles.limit_down,'Enable',Status);%editbox limit min
set(handles.limit_up,'Enable',Status);%editbox limit max
set(handles.zoom_in,'Enable',Status);%button zoom in
set(handles.zoom_reset,'Enable',Status);%button zoom reset
set(handles.pickit,'Enable',Status);%button pick particles
set(handles.pickit,'Visible',Status);%button pick particles
set(handles.Delete,'Enable',Status);%button delete
set(handles.refine,'Enable',Status);%button refine particle
set(handles.refinement_iterations,'Enable',Status);%editbox refine particles
set(handles.power_search,'Enable',Status);%button power search particle
set(handles.transx,'Enable',Status);%editbox translation x 
set(handles.transy,'Enable',Status);%editbox translation y
set(handles.angle,'Enable',Status);%editbox angle 
set(handles.iteration,'Enable',Status);%editbox number of iteration 
set(handles.rotate_avg_angle,'Enable',Status);%editbox rotate avg 
set(handles.filter_avg_low,'Enable',Status);%editbox filter avg low
set(handles.filter_avg_hi,'Enable',Status);%editbox filter avg low
set(handles.filter_avg_apply_filter,'Enable',Status);%checkbox apply filter


% ----------- ClearButtonDownFcn -----------
function ClearButtonDownFcn
%--- Delete the callback in ButtonDownFcn ---
%all the text
T=findall(findobj(0,'Tag','XY_slice'),'Type','text');
for i=1:size(T,1)
    set(T(i),'ButtonDownFcn','');
end
%all the line
L=findall(findobj(0,'Tag','XY_slice'),'Type','line');
for i=1:size(L,1)
    set(L(i),'ButtonDownFcn','');
end
%the main image
I=findall(findobj(0,'Tag','XY_slice'),'Type','image');
set(I,'Tag','MainImage','ButtonDownFcn','');


% ----------- SetButtonDownFcn -----------
function SetButtonDownFcn
%--- set the callback in ButtonDownFcn ---
%all the text
T=findall(findobj(0,'Tag','XY_slice'),'Type','text');
for i=1:size(T,1)
    set(T(i),'ButtonDownFcn','tom_average2d(''MouseDown_Image'',gcbo)');
end
%all the line
L=findall(findobj(0,'Tag','XY_slice'),'Type','line');
for i=1:size(L,1)
    set(L(i),'ButtonDownFcn','tom_average2d(''MouseDown_Image'',gcbo)');
end
%the main image
I=findall(findobj(0,'Tag','XY_slice'),'Type','image');
set(I,'Tag','MainImage','ButtonDownFcn','tom_average2d(''MouseDown_Image'',gcbo)');

