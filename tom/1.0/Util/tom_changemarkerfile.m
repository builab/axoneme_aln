function varargout = tom_changemarkerfile(varargin)
%Deletes a column in a marker file.
%
%SYNTAX
%tom_changemarkerfile
%
%DESCRIPTION
%
%It's an interactive tool to delete a colomn in a marker file. 
%The user has also the possibility to modify the tilt serie.
%
%EXAMPLE
%
%
%SEE ALSO
%TOM_SETMARK
%
%Copyright (c) 2004
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created 06/07/04 WDN

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_changemarkerfile_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_changemarkerfile_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tom_changemarkerfile is made visible.
function tom_changemarkerfile_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for tom_changemarkerfile
handles.output = hObject;
handles.PathMarkerFile='';
handles.NameMarkerFile='';
handles.SizeMF_org='';
handles.SizeMF_mod='';
handles.Column2remove='';
handles.Path_Tiltseries='';
handles.List='';
handles.Image2remove='';
handles.LastProj='';

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes tom_changemarkerfile wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = tom_changemarkerfile_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- BUTTON BROWSE MARKER FILE ---
function browse_MF_Callback(hObject, eventdata, handles)
% initialize the figure
set(handles.panel_TS,'Visible','off');
%set(handles.panel_pathTS,'Visible','off');
set(handles.rmcol,'Enable','off','String','');
set(handles.text_info1,'String','');
set(handles.size_mf,'String','');
set(handles.mf,'String','Select a Marker File');
set(handles.panel_yesno,'Visible','off')
drawnow;
%search for the marker file
[filename, pathname] = uigetfile({'*.em;';'*.*'}, 'Pick an Marker File');
if isequal(filename,0) | isequal(pathname,0)
    %error('Cancel button pressed. No data loaded.');
    return;
end;
handles.PathMarkerFile=pathname;
handles.NameMarkerFile=filename;
set(handles.mf,'String',[handles.PathMarkerFile handles.NameMarkerFile]);
a=tom_reademheader([handles.PathMarkerFile handles.NameMarkerFile]);
dimx=num2str(a.Header.Size(1));
dimy=num2str(a.Header.Size(2));
dimz=num2str(a.Header.Size(3));
set(handles.size_mf,'String',['The Marker File contains '  dimy ' images (size ' dimx ' x ' dimy ' x ' dimz ')']);
set(handles.text_info1,'String','Please, enter the column number to delete in the Marker File');
set(handles.rmcol,'Enable','on');
handles.SizeMF_org=[str2num(dimx);str2num(dimy);str2num(dimz)];
handles.LastProj=str2num(dimy);
guidata(hObject,handles);

% --- EDIT BOX IMAGE NUMBER ---
function rmcol_Callback(hObject, eventdata, handles)
rmc=str2num(get(handles.rmcol,'String'));
if rmc<0 | rmc>handles.SizeMF_org(2)
    message=['Error!!! Out of range'];
    msgbox(message);
    return;
end
message=['You want to delete column number ' get(handles.rmcol,'String') ' of  ' handles.NameMarkerFile '. It''s strongly recommanded to modify the tilt series as well. Do you want to modify the tilt series?' ];
set(handles.text_info1,'String',message);
set(handles.panel_TS,'Visible','on');
set(handles.panel_yesno,'Visible','on');
handles.Column2remove=str2num(get(handles.rmcol,'String'));
org_path=pwd;
cd(handles.PathMarkerFile);
set(handles.path_TS,'String',handles.PathMarkerFile);
handles.Path_Tiltseries=handles.PathMarkerFile;
cd(handles.Path_Tiltseries);
d=dir;
dd=struct2cell(d);
file=dd(1,3:size(dd,2));
handles.List=file;
a=num2str(handles.Column2remove);
for i=1:size(file,2)
    if ~isempty(findstr(file{i},a))
        set(handles.list_TS,'String',file,'Value',i,'Enable','on');
        break;
    end
end
set(handles.text_info2,'Visible','off');
yes_Callback(hObject, eventdata, handles);
cd(org_path);
guidata(hObject,handles);

% --- RADIO BUTTON YES ---
function yes_Callback(hObject, eventdata, handles)
set(handles.rb_yes,'Value',1);
set(handles.rb_no,'Value',0);
set(handles.path_TS,'Enable','on','String',handles.PathMarkerFile);
set(handles.browse_TS,'Enable','on');
set(handles.button_OK,'Enable','off');
set(handles.list_TS,'Enable','off');


% --- RADIO BUTTON NO ---
function no_Callback(hObject, eventdata, handles)
set(handles.rb_yes,'Value',0);
set(handles.rb_no,'Value',1);
set(handles.path_TS,'Enable','off','String','');
set(handles.browse_TS,'Enable','off');
set(handles.list_TS,'Enable','off');
set(handles.button_OK,'Enable','on');
set(handles.text_info2,'String',' ');
%set(handles.panel_pathTS,'Visible','on');



% --- BUTTON BROWSE TILT SERIES ---
function browse_TS_Callback(hObject, eventdata, handles)
org_path=pwd;
cd(handles.PathMarkerFile);
pathname = uigetdir(pwd,'Select a folder');
if isequal(pathname,0)
    %error('Cancel button pressed. No data loaded.');
    return;
end;
set(handles.path_TS,'String',pathname)
handles.Path_Tiltseries=pathname;
cd(handles.Path_Tiltseries);
d=dir;
dd=struct2cell(d);
file=dd(1,3:size(dd,2));
handles.List=file;
a=num2str(handles.Column2remove);
for i=1:size(file,2)
    if ~isempty(findstr(file{i},a))
        set(handles.list_TS,'String',file,'Value',i);
        handles.Image2remove=file{i};
        cd(org_path);
        break;
    end
end
set(handles.list_TS,'Enable','on');
set(handles.button_OK,'Enable','on');
set(handles.text_info2,'Visible','on','String','Note. The rest of the tilt series will be rename');
cd(org_path);
guidata(hObject,handles);

% --- EDIT BOX PATH TILT SERIES ---
function path_TS_Callback(hObject, eventdata, handles)
org_path=pwd;
handles.Path_Tiltseries=get(handles.path_TS,'String');
cd(handles.Path_Tiltseries);
d=dir;
dd=struct2cell(d);
file=dd(1,3:size(dd,2));
handles.List=file;
a=num2str(handles.Column2remove);
for i=1:size(file,2)
    if ~isempty(findstr(file{i},a))
        set(handles.list_TS,'String',file,'Value',i);
        handles.Image2remove=file{i};
        cd(org_path);
        break;
    end
end
set(handles.list_TS,'Enable','on');
set(handles.text_info2,'Visible','on','String','Note. The rest of the tilt series will be rename');
cd(org_path);
guidata(hObject,handles);

% --- POPUP MENU TILT SERIES ---
function list_TS_Callback(hObject, eventdata, handles)
a=get(handles.list_TS,'String'); b=get(handles.list_TS,'Value');
handles.Image2remove=a{b};
guidata(hObject,handles);

% --- BUTTON OK ---
function ok_Callback(hObject, eventdata, handles)
message=('Are you sure you want to process?');
Question=questdlg(message,'Process? ','Yes','No','Yes');
if strcmp(Question,'Yes')
    % Modify MF
    a=tom_emreadc([handles.PathMarkerFile handles.NameMarkerFile]);
    a.Value(:,handles.Column2remove,:)=[];
    a.Header.Size(2)=size(a.Value,2);
    handles.SizeMF_mod=a.Header.Size;
    org_path=pwd;
    cd(handles.PathMarkerFile);
    tom_emwrite(a);
    message=['Marker file modified'];
    msgbox(message);
    if get(handles.rb_yes,'Value')
        % Rename the images in case of 'yes'
        if isempty(findstr(handles.Image2remove,num2str(handles.Column2remove)))
            message=('Error!! Can not process. Colomn number of the Marker file and the image are not compatible');
            msgbox(message)
            return;
        end
        if ~isempty(findstr(handles.Image2remove,'_'))
            a=findstr(handles.Image2remove,'_');
            if size(a,2)>1
                a=a(size(a,2));
            end
            b=findstr(handles.Image2remove,'.');
            if size(b,2)>1
                b=b(size(b,2));
            end
            myf=handles.Image2remove(1:a);
            mye=handles.Image2remove(b:size(handles.Image2remove,2));
        else
            message=('Can not process! Rename your tilt series manually');
            msgbox(message)
            return;
        end

        %delete([handles.Path_Tiltseries '\' handles.Image2remove]);
        for i=handles.Column2remove+1:handles.SizeMF_org(2)
            source_file=[handles.Path_Tiltseries '\' myf num2str(i) mye];
            destination_file=[handles.Path_Tiltseries '\' myf num2str(i-1) mye];
            movefile(source_file,destination_file);
            %delete(source_file);
        end
        message=['Tilt series renamed'];
        msgbox(message);
    end
    set(hObject,'Enable','off');
    cd(org_path);
end
guidata(hObject,handles);

% --- BUTTON NEW SELECTION ---
function button_news_Callback(hObject, eventdata, handles)
set(handles.panel_TS,'Visible','off');
set(handles.rmcol,'Enable','off','String','');
set(handles.text_info1,'String','');
set(handles.size_mf,'String','');
set(handles.mf,'String','Select a Marker File');
set(handles.panel_yesno,'Visible','off')
set(handles.list_TS,'Enable','off');
set(handles.button_OK,'Enable','off');
handles.output = hObject;
handles.PathMarkerFile='';
handles.NameMarkerFile='';
handles.SizeMF_org='';
handles.SizeMF_mod='';
handles.Column2remove='';
handles.Path_Tiltseries='';
handles.List='';
handles.Image2remove='';
handles.LastProj='';
guidata(hObject,handles);

% --- BUTTON EXIT ---
function exit_menu_Callback(hObject, eventdata, handles)
delete(gcf);






