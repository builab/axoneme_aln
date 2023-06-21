function varargout = tom_find_particle_parameters(varargin)
% TOM_FIND_PARTICLE_PARAMETERS M-file for tom_find_particle_parameters.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_find_particle_parameters_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_find_particle_parameters_OutputFcn, ...
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


% --- Executes just before tom_find_particle_parameters is made visible.
function tom_find_particle_parameters_OpeningFcn(hObject, eventdata, handles, varargin)

%interface to main_gui
handles.output = hObject;
handles.Seach_Curr_Image='true';

m=findobj('Tag','average2d');
handles.main_gui=get(m,'UserData');
particle_mask=handles.main_gui.ref;
handles.Binning=0;

filename=strcat(handles.main_gui.Path,'\');
filename=strcat(filename,handles.main_gui.Filename);
pic=tom_emread(filename);
pic=pic.Value;
part_radius=handles.main_gui.radius;
thres_transx=str2num(get(handles.main_gui.transx,'String'));
thres_transy=str2num(get(handles.main_gui.transy,'String'));
thres_angle=str2num(get(handles.main_gui.angle,'String'));
num_of_iterations=str2num(get(handles.main_gui.iteration,'String'));
%end of interface to main_gui

%Hack for Testing
% particle_mask=tom_emread('avg');
% particle_mask=particle_mask.Value;
% folder_path='c:\mytemp\test_data\131103_015.dat';
% pic=tom_emread(folder_path);
% pic=pic.Value;
% part_radius=32;
%end of Hack

%Fill parameters for fine alignment from main Gui
set(handles.fine_alignment_particle_radius,'String',part_radius);
set(handles.fine_alignment_TranslationX,'String',thres_transx);
set(handles.fine_alignment_TranslationY,'String',thres_transy);
set(handles.fine_alignment_Angle,'String',thres_angle);
set(handles.fine_alignment_num_of_iterations,'String',num_of_iterations);

% Fill default parameters for creating Mask
[mean, max, min, std, variance]=tom_dev(particle_mask,'on');
thres=mean;
particle_mask_parameters=[part_radius 0 thres];
mask=tom_make_particle_mask(particle_mask,size(pic,1),particle_mask_parameters);
%val=[mean-std./2 

% initialize Sliders
set(handles.Mask_thres,'Max',(mean+3.*std),'Min',(mean-3.*std),'SliderStep',[0.001 0.001],'Value',thres);
set(handles.Mask_radius,'Max',part_radius,'Min',0,'SliderStep',[0.1 0.1],'Value',part_radius);
set(handles.Mask_smooth,'Max',part_radius,'Min',0,'SliderStep',[0.1 0.1],'Value',0);
set(handles.filter_pic_remove_grad,'Max',(size(pic,1))./2,'Min',0,'SliderStep',[0.1 0.1],'Value',((size(pic,1))./2));
handles.filter_pic_param=get(handles.filter_pic_remove_grad,'Value');
%display mask and image
axes(handles.pic_mask);
tom_imagesc(mask);
axes(handles.pic_picture1);
tom_imagesc(pic);
% Update handles structure
handles.particle_mask_parameters=particle_mask_parameters;
handles.particle_mask=particle_mask;
handles.size_pic=size(pic,1);
handles.pic=pic;
%folder path
handles.folderP=strcat(handles.main_gui.Path,'\');
m=findobj('Tag','Adjust_search_param');
guidata(hObject, handles);
uiwait(m);


% --- Outputs from this function are returned to the command line.
function varargout = tom_find_particle_parameters_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


%***********************************************************


% --- MENU FILE ---
function Menu_file_Callback(hObject, eventdata, handles)

% --- SAVE MARKER FILE ---
function menu_save_marker_file_Callback(hObject, eventdata, handles)
[myname, mypathname] = uiputfile('*.mat', 'SAVE YOUR MARKERPOINT FILE AS');
myfile=[mypathname myname];
if myfile(1)~=0 & myfile(2)~=0 %myfile= 0 0 when 'cancel' is clicked
    if isempty(findstr(myfile,'.mat'))
        myfile=strcat(myfile,'.mat');
    end
    %handles.MarkerPoint(1).ref=handles.ref;
    MarkerPoint=handles.MarkerPoint;
    save(myfile,'MarkerPoint');
end


% --- SLIDER TRES ---
function Mask_thres_Callback(hObject, eventdata, handles)
%set(gcf,'DoubleBuffer','on');
handles.particle_mask_parameters(3)=get(handles.Mask_thres,'Value');
mask=tom_make_particle_mask(handles.particle_mask,handles.size_pic,handles.particle_mask_parameters);
if handles.Binning~=0    
    mask=tom_bin(mask,handles.Binning);
end
axes(handles.pic_mask);
tom_imagesc(mask);
guidata(hObject, handles);

% --- SLIDER RADIUS ---
function Mask_radius_Callback(hObject, eventdata, handles)
%set(gcf,'DoubleBuffer','on');
handles.particle_mask_parameters(1)=get(handles.Mask_radius,'Value');
mask=tom_make_particle_mask(handles.particle_mask,handles.size_pic,handles.particle_mask_parameters);
if handles.Binning~=0    
    mask=tom_bin(mask,handles.Binning);
end
axes(handles.pic_mask);
tom_imagesc(mask);
guidata(hObject, handles);

% --- SLIDER SMOOTH ---
function Mask_smooth_Callback(hObject, eventdata, handles)
%set(gcf,'DoubleBuffer','on');
handles.particle_mask_parameters(2)=get(handles.Mask_smooth,'Value');
mask=tom_make_particle_mask(handles.particle_mask,handles.size_pic,handles.particle_mask_parameters);
if handles.Binning~=0    
    mask=tom_bin(mask,handles.Binning);
end
axes(handles.pic_mask);
tom_imagesc(mask);
guidata(hObject, handles);

% --- SLIDER REMOVE GRAD ---
function filter_pic_remove_grad_Callback(hObject, eventdata, handles)
%set(gcf,'DoubleBuffer','on');
filter_pic_param=get(handles.filter_pic_remove_grad,'Value');
if handles.Binning~=0    
    bin_pic=tom_bin(handles.pic,handles.Binning);
else
    bin_pic=handles.pic;
end
%pic=tom_bandpass(bin_pic,1,round((size(bin_pic,1)/2)));%pic=tom_bandpass(handles.pic,1,round((size(handles.pic,1)/2)));
pic=bin_pic;
ii=tom_bandpass(pic,0,(size(bin_pic,1)/filter_pic_param));
pic=pic./ii;
axes(handles.pic_picture1);
tom_imagesc(pic);

% --- CHECKBOX SEARCH JUST ON CURRENT IMAGE ---
function check_currim_Callback(hObject, eventdata, handles)
sci=get(handles.check_currim,'Value');
if sci
    handles.Seach_Curr_Image='true';
else
    handles.Seach_Curr_Image='false';
end
guidata(hObject, handles);

% --- POPUP BINNING ---
function binning_Callback(hObject, eventdata, handles)
a=get(handles.binning,'String');
b=get(handles.binning,'Value');
handles.Binning=str2num(a{b});
%aa=round(str2num(get(handles.fine_alignment_particle_radius,'String'))/(handles.Binning*2));
if handles.Binning==0    
    aa=handles.main_gui.radius;
    axes(handles.pic_picture1);
    tom_imagesc(handles.pic);  
    mask=tom_make_particle_mask(handles.particle_mask,handles.size_pic,handles.particle_mask_parameters);
    axes(handles.pic_mask);
    tom_imagesc(mask);    
else
    aa=round(handles.main_gui.radius/(handles.Binning*2));
    pic=tom_bin(handles.pic,handles.Binning);
    axes(handles.pic_picture1);
    tom_imagesc(pic); 
    mask=tom_make_particle_mask(handles.particle_mask,handles.size_pic,handles.particle_mask_parameters);
    mask=tom_bin(mask,handles.Binning);
    axes(handles.pic_mask);
    tom_imagesc(mask);        
end
set(handles.fine_alignment_particle_radius,'String',num2str(aa));

guidata(hObject, handles);

% --- BUTTON START ---
function Start_Callback(hObject, eventdata, handles)
handles=get_search_params(hObject, eventdata,handles);
switch handles.Seach_Curr_Image
    case 'true'
        actualfile=[handles.main_gui.Filename];
        mptemp=tom_find_particle_stack(handles.folderP,handles.particle_mask,handles.particle_mask_parameters, ...
        handles.filter_pic_param,handles.max_ccf_of_angles_param,handles.filter_max_ccf_param,handles.fine_align_parameter,...
        actualfile,handles.Binning);          
        for i=1:size(handles.main_gui.List,2)
            st=handles.main_gui.List(i);
            if strcmp(st,mptemp.Filename) 
                handles.main_gui.MarkerPoint(i).Filename=cellstr(mptemp.Filename);
                handles.main_gui.MarkerPoint(i).X=mptemp.X;
                handles.main_gui.MarkerPoint(i).Y=mptemp.Y;
                handles.main_gui.MarkerPoint(i).Angle=mptemp.Angle;
                handles.main_gui.MarkerPoint(i).refine_success=mptemp.refine_success;
                handles.main_gui.MarkerPoint(1).NumberParticle=mptemp.NumberParticle;
                handles.main_gui.MarkerPoint(1).ref=mptemp.ref;
            end
        end
        handles.MarkerPoint=handles.main_gui.MarkerPoint ;       
    
    case 'false'
        handles.MarkerPoint=tom_find_particle_stack(handles.folderP,handles.particle_mask,handles.particle_mask_parameters, ...
        handles.filter_pic_param,handles.max_ccf_of_angles_param,handles.filter_max_ccf_param,handles.fine_align_parameter,...
        -1,handles.Binning); 
end
if handles.Binning~=0 %restore ref in case of binning
    myfile=[handles.folderP 'reference.mat'];
    load(myfile);
    handles.MarkerPoint(1).ref=myref;
    delete(myfile);
end
handles.output=handles.MarkerPoint;
m=findobj('Tag','Adjust_search_param');
guidata(hObject, handles);
uiresume(m);
%delete(m);

% --- BUTTON QUIT ---
function quit_Callback(hObject, eventdata, handles)
m=findobj('Tag','Adjust_search_param');
handles.output=[];%handles.main_gui.MarkerPoint ;
guidata(hObject, handles);
uiresume(m);
%delete(m)


function Number_of_Particles_Angles_Callback(hObject, eventdata, handles)

function Number_of_Particles_Callback(hObject, eventdata, handles)

function fine_alignment_get_Values_from_gui_Callback(hObject, eventdata, handles)

function fine_alignment_TranslationY_Callback(hObject, eventdata, handles)

function fine_alignment_TranslationX_Callback(hObject, eventdata, handles)

function fine_alignment_Angle_Callback(hObject, eventdata, handles)

function fine_alignment_particle_radius_Callback(hObject, eventdata, handles)

function fine_alignment_num_of_iterations_Callback(hObject, eventdata, handles)

function delta_of_angles_Callback(hObject, eventdata, handles)

%********************************************************************
%*****   Other function  ********************************************
%********************************************************************

% --- GET_SEARCH_PARAMS ---
function handles=get_search_params(hObject,eventdata,handles)
% fine align parameters
handles.fine_align_parameter(1)=str2num(get(handles.fine_alignment_particle_radius,'String'));
handles.fine_align_parameter(2)=str2num(get(handles.fine_alignment_num_of_iterations,'String'));
handles.fine_align_parameter(3)=str2num(get(handles.fine_alignment_Angle,'String'));
handles.fine_align_parameter(4)=str2num(get(handles.fine_alignment_TranslationX,'String'));
handles.fine_align_parameter(5)=str2num(get(handles.fine_alignment_TranslationY,'String'));
handles.fine_align_parameter(6)=((handles.fine_align_parameter(5)+handles.fine_align_parameter(4))./2)+2;
%particle mask parameters
handles.paricle_mask_parameters(1)=get(handles.Mask_radius,'Value');
handles.paricle_mask_parameters(2)=get(handles.Mask_smooth,'Value');
handles.paricle_mask_parameters(3)=get(handles.Mask_thres,'Value');
%filter paramer
handles.filter_pic_param=get(handles.filter_pic_remove_grad,'Value');
%max_ccf_of_angles_param
handles.max_ccf_of_angles_param(1)=str2num(get(handles.Number_of_Angles,'String'));
handles.max_ccf_of_angles_param(2)=str2num(get(handles.delta_of_angles,'String'));
%filter_max_ccf_param
handles.filter_max_ccf_param(1)=str2num(get(handles.Number_of_Particles,'String'));
handles.filter_max_ccf_param(2)=handles.fine_align_parameter(1);
guidata(hObject,handles);




