function varargout = tom_volxyz(varargin)
%3D visualization tool for tomograms. 
%
%SYNTAX
%tom_volxyz(inp_vol)
%
%DESCRIPTION
%This function is used to view a volume inp_vol directly from the memory. 
%It is a GUI to scan through the volume in x,y and z direction and lets you adjust 
%the contrast interactively. Additionally, a running average in every direction
%can be calculated to increase the contrast. A bandpass filter can be applied
%in each direction.
%  
%EXAMPLE
%a=tom_emread('pyrodictium.vol');
%tom_volxyz(a.Value);
%
%SEE ALSO
%TOM_INTERVOL, TOM_VOLXY, TOM_PARTICLES
%
%Copyright (c) 2005
%TOM toolbox for Electron Tomography
%Max-Planck-Institute for Biochemistry
%Dept. Molecular Structural Biology
%82152 Martinsried, Germany
%http://www.biochem.mpg.de/tom
%
%Created: 20/03/05 Andreas Korinek
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tom_volxyz_OpeningFcn, ...
                   'gui_OutputFcn',  @tom_volxyz_OutputFcn, ...
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


% --- Executes just before tom_volxyz is made visible.
function tom_volxyz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tom_volxyz (see VARARGIN)

% Choose default command line output for tom_volxyz
handles.output = hObject;

if isstruct(varargin{1})
    handles.Volume=varargin{1};
    set(handles.volume_name,'String',handles.Volume.Header.Filename);
else
    handles.Volume=tom_emheader(varargin{1});
end

handles.dimensions.x=handles.Volume.Header.Size(1);
handles.dimensions.y=handles.Volume.Header.Size(2);
handles.dimensions.z=handles.Volume.Header.Size(3);

handles.figures.vline_xy = [];
handles.figures.hline_xy = [];
handles.figures.hline_xz = [];
handles.figures.hline_yz = [];
handles.actualaxis.xy = [1 handles.dimensions.x 1 handles.dimensions.y];
handles.actualaxis.xz = [1 handles.dimensions.x 1 handles.dimensions.z];
handles.actualaxis.yz = [1 handles.dimensions.z 1 handles.dimensions.y];
handles.zoom.quadratic = 1;
handles.lines.data = [];
handles.subvol.data = [];

handles.lines.index = 1;
set(handles.filter_low,'String',0);
set(handles.filter_high,'String',handles.dimensions.x / 2);


guidata(hObject, handles);

outer_padding = 50;
inner_padding = 20;
outerdiff = 20;

%Create image slice window
handles.figures.image = figure();

set(handles.figures.image,'Tag','imagewindow');
set(handles.figures.image,'Name','tom_volxyz');
set(handles.figures.image,'Resize','on');
%set(handles.figures.image,'Renderer','OpenGL');
set(handles.figures.image,'DoubleBuffer','on');
width = outer_padding * 2 + inner_padding + handles.dimensions.z + handles.dimensions.x;
height = outer_padding * 2 + inner_padding + handles.dimensions.y + handles.dimensions.z;
set(handles.figures.image,'Position',[100 100 width height]);
set(handles.figures.image,'ToolBar','none');
set(handles.figures.image,'MenuBar','none');


%Position of xy Slice
handles.axes.xy = axes();
axis ij;
left = outer_padding;
bottom = outer_padding + handles.dimensions.z + inner_padding;
width = handles.dimensions.x;
height = handles.dimensions.y;
set(handles.axes.xy,'Units','pixel');
set(handles.axes.xy,'Tag','xy_axes');
set(handles.axes.xy, 'Position', [left bottom width height],'visible','on');
%set(handles.axes.xy, 'OuterPosition', [left-outerdiff bottom-outerdiff width+2*outerdiff height+2*outerdiff]);
set(handles.axes.xy,'Units','normalized');

%Position of xz slice
handles.axes.xz = axes();
axis ij;
left = outer_padding;
bottom = outer_padding;
width = handles.dimensions.x;
height = handles.dimensions.z;
set(handles.axes.xz,'Units','pixel');
set(handles.axes.xz, 'Tag', 'xz_axes');
set(handles.axes.xz, 'Position', [left bottom width height],'visible','on');
%set(handles.axes.xz, 'OuterPosition', [left-outerdiff bottom-outerdiff width+2*outerdiff height+2*outerdiff]);
set(handles.axes.xz,'Units','normalized');

%Position of yz slice
handles.axes.yz = axes();
axis ij;
left = outer_padding + inner_padding + handles.dimensions.x;
bottom = outer_padding + handles.dimensions.z + inner_padding;
width = handles.dimensions.z;
height = handles.dimensions.y;
set(handles.axes.yz,'Units','pixel');
set(handles.axes.yz,'Tag','yz_axes');
set(handles.axes.yz, 'Position', [left bottom width height],'visible','on');
%set(handles.axes.yz, 'OuterPosition', [left-outerdiff bottom-outerdiff width+2*outerdiff height+2*outerdiff]);
set(handles.axes.yz,'Units','normalized');
set(handles.axes.yz,'YAxisLocation','right','Color','none');

guidata(hObject, handles);


% position sliders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tmp_obj=findobj('Tag','x_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.x)
set(tmp_obj,'SliderStep',[1./handles.dimensions.x 5./handles.dimensions.x]);
set(tmp_obj,'Value', round(handles.dimensions.x/2));
set(handles.text_x,'String',num2str(round(handles.dimensions.x/2)));

tmp_obj=findobj('Tag','y_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.y)
set(tmp_obj,'SliderStep',[1./handles.dimensions.y 5./handles.dimensions.y]);
set(tmp_obj,'Value',round(handles.dimensions.y/2));
set(handles.text_y,'String',num2str(round(handles.dimensions.y/2)));


tmp_obj=findobj('Tag','z_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.z)
set(tmp_obj,'SliderStep',[1./handles.dimensions.z 5./handles.dimensions.z]);
set(tmp_obj,'Value',round(handles.dimensions.z/2));
set(handles.text_z,'String',num2str(round(handles.dimensions.z/2)));

% Average sliders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp_obj=findobj('Tag','avg_x_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.x)
set(tmp_obj, 'Value', 1);
set(tmp_obj,'SliderStep',[1./handles.dimensions.x 1./handles.dimensions.x]);
set(handles.avg_x_text,'String',num2str(1));

tmp_obj=findobj('Tag','avg_y_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.y)
set(tmp_obj, 'Value', 1);
set(tmp_obj,'SliderStep',[1./handles.dimensions.y 1./handles.dimensions.y]);
set(handles.avg_y_text,'String',num2str(1));

tmp_obj=findobj('Tag','avg_z_slider');
set(tmp_obj,'Min',1);
set(tmp_obj,'Max',handles.dimensions.z)
set(tmp_obj, 'Value', 1);
set(tmp_obj,'SliderStep',[1./handles.dimensions.z 1./handles.dimensions.z]);
set(handles.avg_z_text,'String',num2str(1));


handles.position.xy = handles.dimensions.z/2;
handles.position.xz = handles.dimensions.y/2;
handles.position.yz = handles.dimensions.x/2;
handles.clickmode = 'setpoint';
%set(handles.figures.image,'Units','characters');

%set(handles.figures.image,'ResizeFcn',);

%Calculate histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for lauf=1:500
    rand_pos=rand(3,1);
    rand_pos(1)=rand_pos(1) * handles.dimensions.x;
    rand_pos(2)=rand_pos(2) * handles.dimensions.y;
    rand_pos(3)=rand_pos(3) * handles.dimensions.z;
    
    rand_pos(1)=floor(rand_pos(1)+1);
    rand_pos(2)=floor(rand_pos(2)+1);
    rand_pos(3)=floor(rand_pos(3)+1);
       
    rand_pos(1)= rand_pos(1)-10;
    rand_pos(2)= rand_pos(2)-10;
    
    if rand_pos(1) < 1
    	rand_pos(1) = 1;
    end
    if rand_pos(2) < 1
    	rand_pos(2) = 1;
    end
      
    tmp = double(handles.Volume.Value(rand_pos(1):rand_pos(1)+8,rand_pos(2):rand_pos(2)+8,rand_pos(3)));
    tmpp(:,:,lauf)=tmp;
end;
handles.histogramdata = tmpp;

guidata(hObject, handles);

calc_hist(hObject, eventdata, handles);

handles.orientation='xy';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

handles.orientation='xz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);
		
handles.orientation='yz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

%set(handles.figures.image,'ResizeFcn',@(h,e)(resize_window(hObject,eventdata,handles)));
% UIWAIT makes tom_volxyz wait for user response (see UIRESUME)
% uiwait(handles.tom_volxyz);


% --- Outputs from this function are returned to the command line.
function varargout = tom_volxyz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Recalculate image positions on window resize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function resize_window(hObject, eventdata, handles)
figure(handles.figures.image);
figuredimensions = get(handles.figures.image,'Position');

outer_padding = 50;
inner_padding = 20;
outerdiff = 20;

figurewidth = figuredimensions(3) - outer_padding * 2 - inner_padding;
figureheight = figuredimensions(4) - outer_padding * 2 - inner_padding;
yfrac = handles.dimensions.y / (handles.dimensions.z + handles.dimensions.y);
xfrac = handles.dimensions.x / (handles.dimensions.z + handles.dimensions.x);
zfrac = handles.dimensions.z / (handles.dimensions.z + handles.dimensions.y);

zsize = figureheight * zfrac;
xsize = figurewidth * xfrac;
ysize = figureheight * yfrac;


%Position of xy Slice
axes(handles.axes.xy);
axis ij;
left = outer_padding;
bottom = outer_padding + zsize + inner_padding;
width = xsize;
height = ysize;
set(handles.axes.xy,'Units','pixel');
set(handles.axes.xy,'Tag','xy_axes');
set(handles.axes.xy, 'Position', [left bottom width height],'visible','on');

set(handles.axes.xy,'Units','normalized');

%Position of xz slice
axes(handles.axes.xz);
axis ij;
left = outer_padding;
bottom = outer_padding;
width = xsize;
height = zsize;
set(handles.axes.xz,'Units','pixel');
set(handles.axes.xz, 'Tag', 'xz_axes');
set(handles.axes.xz, 'Position', [left bottom width height],'visible','on');
set(handles.axes.xz,'Units','normalized');

%Position of yz slice
axes(handles.axes.yz);
axis ij;
left = outer_padding + inner_padding + xsize;
bottom = outer_padding + zsize + inner_padding;
width = zsize;
height = ysize;
set(handles.axes.yz,'Units','pixel');
set(handles.axes.yz,'Tag','yz_axes');
set(handles.axes.yz, 'Position', [left bottom width height],'visible','on');
set(handles.axes.yz,'Units','normalized');
set(handles.axes.yz,'YAxisLocation','right','Color','none');
%guidata(hObject, handles);
redraw_all_slices(hObject, eventdata, handles);
%guidata(hObject, handles);

%Redraw all slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function redraw_all_slices(hObject, eventdata, handles)

handles.orientation = 'xy';
guidata(hObject,handles);
render_slice(hObject, eventdata, handles);

handles.orientation = 'xz';
guidata(hObject,handles);
render_slice(hObject, eventdata, handles);

handles.orientation = 'yz';
guidata(hObject,handles);
render_slice(hObject, eventdata, handles);

%Calculate histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calc_hist(hObject, eventdata, handles)

[mean max min std]=tom_dev(handles.histogramdata,'noinfo');
handles.DataScale=[mean-2*std mean+2*std];
[h,n]=tom_hist3d(handles.histogramdata);
%[h,n]=tom_hist3d(handles.Volume.Value(:,:,1));
handles.DataScale=[n(1)  n(size(n,2))];
h=200.*h./(100.*handles.Volume.Header.Size(1).*handles.Volume.Header.Size(2).*handles.Volume.Header.Size(3));
axes(handles.histogram);bar(n,h);axis auto;
set(handles.limit_down,'String',handles.DataScale(1));
set(handles.limit_up,'String',handles.DataScale(2));

guidata(hObject,handles);

%Set coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_position(hObject, eventdata, handles)

point1=get(gca,'currentpoint');
orientation = get(gcbo,'Tag');
button = get(gcf,'selectiontype');

%button values:
%normal: left mouse button
%alt: right mouse button
%extend: middle mouse buttons

pt = point1(1,1:2);
x1 = round(pt(1));
y1 = round(pt(2));

%Handle Set Position event (left mouse button)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(button,'normal') == true

	if orientation == 'xy_image' | orientation == 'hline_xy' | orientation == 'vline_xy'
		handles.position.xz = y1;
		handles.position.yz = x1;
	elseif orientation == 'xz_image' | orientation == 'hline_xz' | orientation == 'vline_xz'
		handles.position.xy = y1;
		handles.position.yz = x1;
	elseif orientation == 'yz_image' | orientation == 'hline_yz' | orientation == 'vline_yz'
		handles.position.xy = x1;
		handles.position.xz = y1;
	end

%Handle Set Marker Points event (right mouse button)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(button,'alt') == true

	if orientation == 'xy_image' | orientation == 'hline_xy' | orientation == 'vline_xy'
		handles.lines.data(handles.lines.index) = [handles.lines.data(handles.lines.index); [x1, y1, handles.position.xy]];
		disp(handles.lines.data);
	elseif orientation == 'xz_image' | orientation == 'hline_xz' | orientation == 'vline_xz'
	
	elseif orientation == 'yz_image' | orientation == 'hline_yz' | orientation == 'vline_yz'
	
	end

end


redraw_all_slices(hObject, eventdata, handles);

set(handles.x_slider, 'Value', handles.position.yz);
set(handles.text_x, 'String', num2str(handles.position.yz));
set(handles.y_slider, 'Value', handles.position.xz);
set(handles.text_y, 'String', num2str(handles.position.xz));
set(handles.z_slider, 'Value', handles.position.xy);
set(handles.text_z, 'String', num2str(handles.position.xy));


function set_callbacks(hObject, eventdata, handles)

tmpobj = findobj('Tag','xy_image');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
tmpobj = findobj('Tag','xz_image');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
tmpobj = findobj('Tag','yz_image');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_xy');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_xy');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_xz');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_xz');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_yz');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_yz');
set(tmpobj,'buttonDownFcn',@(h,e)(set_position(hObject, eventdata, handles)));
guidata(hObject,handles);


function unset_callbacks(hObject, eventdata, handles)

tmpobj = findobj('Tag','xy_image');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
tmpobj = findobj('Tag','xz_image');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
tmpobj = findobj('Tag','yz_image');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_xy');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_xy');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_xz');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_xz');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));

tmpobj = findobj('Tag','vline_yz');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
tmpobj = findobj('Tag','hline_yz');
set(tmpobj,'buttonDownFcn',@(h,e)(dummy(hObject, eventdata, handles)));
guidata(hObject,handles);


function dummy(hObject, eventdata, handles)

%Render slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function render_slice(hObject, eventdata, handles)
set(handles.figures.image,'ResizeFcn',@(h,e)(resize_window(hObject,eventdata,handles)));
tmp_obj=findobj('Tag','limit_down');

down = get(tmp_obj,'String');
tmp_obj=findobj('Tag','limit_up');
up = get(tmp_obj,'String');

try
	handles.DataScale = [str2num(down{2}) str2num(up{2})];
catch
	handles.DataScale = [str2num(down) str2num(up)];
end

if handles.orientation == 'xy'
	
	tmp_obj=findobj('Tag','avg_z_text');
	sliceavg=round(str2num(get(tmp_obj,'String')));
	sliceavg = round(sliceavg+0.1/2);
	
	if handles.position.xy + sliceavg > handles.dimensions.z
    		sliceavg=handles.dimensions.z-handles.position.xy;
	end
	if handles.position.xy - sliceavg < 1
		sliceavg=0;
	end
	
	if handles.position.xy > 0 & handles.position.xy <= handles.dimensions.z
		slice = squeeze(handles.Volume.Value(:,:,round(handles.position.xy-sliceavg):round(handles.position.xy+sliceavg)));
		slice = mean(double(slice), 3);
		axes(handles.axes.xy);

		if get(handles.filter_xy,'Value') ~= 0
			slice = tom_bandpass(double(slice), str2num(get(handles.filter_low,'String')), str2num(get(handles.filter_high,'String')));
			handles.DataScale(1) = handles.DataScale(1)./ (handles.dimensions.x*handles.dimensions.y);
			handles.DataScale(2) = handles.DataScale(2)./ (handles.dimensions.x*handles.dimensions.y);
		end
		
		handles.images.xy = imagesc(slice',[handles.DataScale]);colormap(gray);axis ij; axis(handles.actualaxis.xy);
		set(handles.images.xy, 'Tag', 'xy_image');
		set(handles.axes.yz,'Units','normalized');
	end
	
elseif handles.orientation == 'xz'

	tmp_obj=findobj('Tag','avg_y_text');
	sliceavg=round(str2num(get(tmp_obj,'String')));

	if handles.position.xz + sliceavg > handles.dimensions.y
    		sliceavg=handles.dimensions.y-handles.position.xz;
	end
	if handles.position.xz - sliceavg < 1
		sliceavg=0;
	end

	if handles.position.xz > 0 & handles.position.xz <= handles.dimensions.y
		slice = handles.Volume.Value(:,round(handles.position.xz-sliceavg):round(handles.position.xz+sliceavg),:);
		slice = mean(double(slice), 2);
		slice = squeeze(slice);
		axes(handles.axes.xz);

		if get(handles.filter_xz,'Value') ~= 0
			slice = tom_bandpass(double(slice), str2num(get(handles.filter_low,'String')), str2num(get(handles.filter_high,'String')));
			handles.DataScale(1) = handles.DataScale(1)./ (handles.dimensions.x*handles.dimensions.z);
			handles.DataScale(2) = handles.DataScale(2)./ (handles.dimensions.x*handles.dimensions.z);
		end

		handles.images.xz = imagesc(slice',[handles.DataScale]);colormap(gray);axis ij;axis(handles.actualaxis.xz);
		set(handles.images.xz, 'Tag', 'xz_image');
		set(handles.axes.yz,'Units','normalized');
	end

elseif handles.orientation == 'yz'

	tmp_obj=findobj('Tag','avg_x_text');
	sliceavg=round(str2num(get(tmp_obj,'String')));

	if handles.position.yz + sliceavg > handles.dimensions.x
    		sliceavg=handles.dimensions.x-handles.position.yz;
	end
	if handles.position.yz - sliceavg < 1
		sliceavg=0;
	end

	if handles.position.yz > 0 & handles.position.yz <= handles.dimensions.x
		slice = handles.Volume.Value(round(handles.position.yz-sliceavg):round(handles.position.yz+sliceavg),:,:);
		slice = mean(double(slice), 1);
		slice = squeeze(slice);
		axes(handles.axes.yz);

		if get(handles.filter_yz,'Value') ~= 0
			slice = tom_bandpass(double(slice), str2num(get(handles.filter_low,'String')), str2num(get(handles.filter_high,'String')));
			[mean2, max, min, std, variance] = tom_dev(slice,'noinfo');
			handles.DataScale(1) = handles.DataScale(1)./ (handles.dimensions.y*handles.dimensions.z);
			handles.DataScale(2) = handles.DataScale(2)./ (handles.dimensions.y*handles.dimensions.z);
		end

		handles.images.yz = imagesc(slice,[handles.DataScale]);colormap(gray);axis ij;axis(handles.actualaxis.yz);
		set(handles.images.yz, 'Tag', 'yz_image');
		set(handles.axes.yz,'YAxisLocation','right');
		set(handles.axes.yz,'Units','normalized');
	end



end

%Draw Position markers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.axes.xy);
set(handles.axes.xy,'Units','pixel');
h = findobj('Tag','hline_xy');
delete(h);
h = findobj('Tag','vline_xy');
delete(h);

y1 = handles.position.xz;
handles.figures.hline_xy = line('Xdata', [0 handles.dimensions.x], 'Ydata', [y1 y1], 'Color', 'r', 'LineWidth',1, 'Tag', 'hline_xy','ButtonDownFcn',@(h,e)set_position(hObject,eventdata,handles));

x1 = handles.position.yz;
handles.figures.vline_xy = line('Xdata', [x1 x1], 'Ydata', [0 handles.dimensions.y], 'Color', 'r', 'LineWidth',1, 'Tag', 'vline_xy');
set(handles.axes.xy,'Units','normalized');

axes(handles.axes.xz);
set(handles.axes.xz,'Units','pixel');
h = findobj('Tag','hline_xz');
delete(h);
h = findobj('Tag','vline_xz');
delete(h);

handles.figures.hline_xz = line('Xdata', [0 handles.dimensions.x], 'Ydata', [handles.position.xy handles.position.xy], 'Color', 'r', 'LineWidth',1, 'Tag', 'hline_xz');
handles.figures.vline_xz = line('Xdata', [handles.position.yz handles.position.yz], 'Ydata', [0 handles.dimensions.z], 'Color', 'r', 'LineWidth', 1, 'Tag', 'vline_xz');
set(handles.axes.xy,'Units','normalized');

axes(handles.axes.yz);
set(handles.axes.yz,'Units','pixel');
h = findobj('Tag','vline_yz');
delete(h);
h = findobj('Tag','hline_yz');
delete(h);

handles.figures.vline_yz = line('Xdata', [handles.position.xy handles.position.xy], 'Ydata', [0 handles.dimensions.y], 'Color', 'r', 'LineWidth',1, 'Tag', 'vline_yz');
handles.figures.hline_yz = line('Xdata', [0 handles.dimensions.z], 'Ydata', [handles.position.xz handles.position.xz], 'Color', 'r', 'LineWidth',1, 'Tag', 'vline_yz');
set(handles.axes.xy,'Units','normalized');
set_callbacks(hObject, eventdata, handles);
guidata(hObject, handles);

%Draw subvolume box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if handles.subvol.data ~= 0
	
	x1 = handles.subvol.data(1);
	x2 = handles.subvol.data(2);
	y1 = handles.subvol.data(3);
	y2 = handles.subvol.data(4);
	z1 = handles.subvol.data(5);
	z2 = handles.subvol.data(6);
	axes(handles.axes.xy);
	handles.figures.rect_xy = rectangle('Position',[x1 y1 abs(x2 - x1) abs(y2 - y1)],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect');
	
	axes(handles.axes.xz);
	rectangle('Position',[x1 z1 abs(x2 - x1) abs(z2 - z1)],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect');
	
	axes(handles.axes.yz);
	rectangle('Position',[z1 y1 abs(z2 - z1) abs(y2 - y1)],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect');
end

% --- Executes on slider movement.
function x_slider_Callback(hObject, eventdata, handles)
% hObject    handle to x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliceyz=round(get(hObject,'Value'));
set(handles.text_x,'String',num2str(sliceyz));

sliceyz=round(eval(get(handles.text_x,'String')));
if sliceyz>handles.dimensions.x
    sliceyz=handles.handles.dimensions.x;
    set(handles.x_slider,'Value',sliceyz);
    set(handles.text_x,'String',sliceyz);
elseif sliceyz<1
    sliceyz=1;
    set(handles.x_slider,'Value',sliceyz);
    set(handles.text_x,'String',sliceyz);
end

handles.orientation = 'yz';
handles.position.yz = sliceyz;
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function x_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function y_slider_Callback(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slicexz=round(get(hObject,'Value'));
set(handles.text_y,'String',num2str(slicexz));

slicexz=round(eval(get(handles.text_y,'String')));
if slicexz>handles.dimensions.y
    slicexz=handles.handles.dimensions.y;
    set(handles.y_slider,'Value',slicexz);
    set(handles.text_y,'String',slicexz);
elseif slicexz<1
    slicexz=1;
    set(handles.y_slider,'Value',slicexz);
    set(handles.text_y,'String',slicexz);
end

handles.orientation = 'xz';
handles.position.xz = slicexz;

guidata(hObject, handles);
render_slice(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function y_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

slicexy=round(get(hObject,'Value'));
set(handles.text_z,'String',num2str(slicexy));

slicexy=round(eval(get(handles.text_z,'String')));
if slicexy>handles.dimensions.z
    slicexy=handles.dimensions.z;
    set(handles.z_slider,'Value',slicexy);
    set(handles.text_z,'String',slicexy);
elseif slicexy<1
    slicexy=1;
    set(handles.z_slider,'Value',slicexy);
    set(handles.text_z,'String',slicexy);
end

handles.orientation = 'xy';
handles.position.xy = slicexy;
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function text_x_Callback(hObject, eventdata, handles)
% hObject    handle to text_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_x as text
%        str2double(get(hObject,'String')) returns contents of text_x as a double
editx=round(eval(get(handles.text_x,'String')));
set(handles.x_slider,'Value',editx);

handles.position.yz = editx;
handles.orientation = 'yz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function text_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_y_Callback(hObject, eventdata, handles)
% hObject    handle to text_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_y as text
%        str2double(get(hObject,'String')) returns contents of text_y as a double

edity=round(eval(get(handles.text_y,'String')));
set(handles.y_slider,'Value',edity);

handles.position.xz = edity;
handles.orientation = 'xz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function text_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_z_Callback(hObject, eventdata, handles)
% hObject    handle to text_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_z as text
%        str2double(get(hObject,'String')) returns contents of text_z as a double

editz=round(eval(get(handles.text_z,'String')));
set(handles.z_slider,'Value',editz);
handles.position.xy = editz;
handles.orientation = 'xy';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function text_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_zoom.
function button_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to button_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unset_callbacks(hObject, eventdata, handles);

guidata(hObject,handles);

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions

if handles.zoom.quadratic == 1
	offset(1) = offset(2);
	
	xdim = offset(1);
	ydim = offset(1);
	zdim = offset(1);
else
	xdim = handles.dimensions.x;
	ydim = handles.dimensions.y;
	zdim = handles.dimensions.z;
	
end

orientation = get(gco,'Tag');

if orientation == 'xy_image'
	x = [p1(1) p1(1)+offset(1)];
	y = [p1(2) p1(2)+offset(2)];
	x=round(x);
	y=round(y);
	
	handles.actualaxis.xy=[x(1) x(2) y(1) y(2)];
	handles.actualaxis.xz=[x(1) x(2) handles.position.xy-zdim/2 handles.position.xy+zdim/2];
	handles.actualaxis.yz=[handles.position.xy-zdim/2 handles.position.xy+zdim/2 y(1) y(2)];
elseif orientation == 'xz_image'
	x = [p1(1) p1(1)+offset(1)];
	z = [p1(2) p1(2)+offset(2)];
	x=round(x);
	z=round(z);
	
	handles.actualaxis.xy=[x(1) x(2) handles.position.xy-ydim/2 handles.position.xy+ydim/2];
	handles.actualaxis.xz=[x(1) x(2) z(1) z(2)];
	handles.actualaxis.yz=[z(1) z(2) handles.position.xy-ydim/2 handles.position.xy+ydim/2];
elseif orientation == 'yz_image'
	z = [p1(1) p1(1)+offset(1)];
	y = [p1(2) p1(2)+offset(2)];
	z=round(z);
	y=round(y);
	
	handles.actualaxis.xy=[handles.position.yz-xdim/2 handles.position.yz+xdim/2 y(1) y(2)];
	handles.actualaxis.xz=[handles.position.yz-xdim/2 handles.position.yz+xdim/2 z(1) z(2)];
	handles.actualaxis.yz=[z(1) z(2) y(1) y(2)];
end

redraw_all_slices(hObject, eventdata, handles);

set_callbacks(hObject, eventdata, handles);
guidata(hObject,handles);


% --- Executes on button press in button_zoomreset.
function button_zoomreset_Callback(hObject, eventdata, handles)
% hObject    handle to button_zoomreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.actualaxis.xy = [1 handles.dimensions.x 1 handles.dimensions.y];
handles.actualaxis.xz = [1 handles.dimensions.x 1 handles.dimensions.z];
handles.actualaxis.yz = [1 handles.dimensions.z 1 handles.dimensions.y];

redraw_all_slices(hObject, eventdata, handles);

guidata(hObject,handles);

function zoom_quadratic_Callback(hObject, eventdata, handles)

if handles.zoom.quadratic == 0
	handles.zoom.quadratic = 1;
else
	handles.zoom.quadratic  = 0;
end

guidata(hObject,handles);

% --- Executes on slider movement.
function avg_x_slider_Callback(hObject, eventdata, handles)
% hObject    handle to avg_x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliceavg=round(get(hObject,'Value'));
set(handles.avg_x_text,'String',num2str(sliceavg));

% --- Executes during object creation, after setting all properties.
function avg_x_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_x_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function avg_y_slider_Callback(hObject, eventdata, handles)
% hObject    handle to avg_y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliceavg=round(get(hObject,'Value'));
set(handles.avg_y_text,'String',num2str(sliceavg));

% --- Executes during object creation, after setting all properties.
function avg_y_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_y_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function avg_z_slider_Callback(hObject, eventdata, handles)
% hObject    handle to avg_z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliceavg=round(get(hObject,'Value'));
set(handles.avg_z_text,'String',num2str(sliceavg));

% --- Executes during object creation, after setting all properties.
function avg_z_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_z_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function avg_x_text_Callback(hObject, eventdata, handles)
% hObject    handle to avg_x_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of avg_x_text as text
%        str2double(get(hObject,'String')) returns contents of avg_x_text as a double

tmp_obj=findobj('Tag','avg_x_text');
get(tmp_obj,'Value');
sliceavg=round(eval(get(tmp_obj,'String')));
if sliceavg<1 sliceavg=1; set(tmp_obj,'String',sliceavg); end;
if sliceavg>handles.dimensions.x sliceavg=handles.dimensions.x; set(tmp_obj,'String',sliceavg); end;
tmp_obj=findobj('Tag','avg_x_slider');
set(tmp_obj,'Value',sliceavg);

% --- Executes during object creation, after setting all properties.
function avg_x_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_x_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function avg_y_text_Callback(hObject, eventdata, handles)
% hObject    handle to avg_y_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of avg_y_text as text
%        str2double(get(hObject,'String')) returns contents of avg_y_text as a double

tmp_obj=findobj('Tag','avg_y_text');
get(tmp_obj,'Value');
sliceavg=round(eval(get(tmp_obj,'String')));
if sliceavg<1 sliceavg=1; set(tmp_obj,'String',sliceavg); end;
if sliceavg>handles.dimensions.y sliceavg=handles.dimensions.y; set(tmp_obj,'String',sliceavg); end;
tmp_obj=findobj('Tag','avg_y_slider');
set(tmp_obj,'Value',sliceavg);

% --- Executes during object creation, after setting all properties.
function avg_y_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_y_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function avg_z_text_Callback(hObject, eventdata, handles)
% hObject    handle to avg_z_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of avg_z_text as text
%        str2double(get(hObject,'String')) returns contents of avg_z_text as a double

tmp_obj=findobj('Tag','avg_z_text');
get(tmp_obj,'Value');
sliceavg=round(eval(get(tmp_obj,'String')));
if sliceavg<1 sliceavg=1; set(tmp_obj,'String',sliceavg); end;
if sliceavg>handles.dimensions.z sliceavg=handles.dimensions.z; set(tmp_obj,'String',sliceavg); end;
tmp_obj=findobj('Tag','avg_z_slider');
set(tmp_obj,'Value',sliceavg);

% --- Executes during object creation, after setting all properties.
function avg_z_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avg_z_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_histogram.
function reset_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to reset_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

calc_hist(hObject, eventdata, handles);

min=str2num(get(handles.limit_down,'String'));
max=str2num(get(handles.limit_up,'String'));
handles.DataScale=[min max];
guidata(hObject,handles);
set(handles.histogram,'Xlim',[min max]);

redraw_all_slices(hObject, eventdata, handles);
guidata(hObject, handles);

handles.orientation='xy';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

handles.orientation='xz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);
		
handles.orientation='yz';
guidata(hObject, handles);
render_slice(hObject, eventdata, handles);

% --- Executes on button press in set_histogram.
function set_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to set_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.histogram);
k = waitforbuttonpress;
     point1 = get(gca,'CurrentPoint');    % button down detected
     finalRect = rbbox;                   % return figure units
     point2 = get(gca,'CurrentPoint');    % button up detected
     point1 = point1(1,1:2);              % extract x and y
     point2 = point2(1,1:2);
     p1 = min(point1,point2);             % calculate locations
     offset = abs(point1-point2);         % and dimensions
     x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
handles.DataScale=[x(1) x(2)];
set(handles.limit_down,'String',handles.DataScale(1));
set(handles.limit_up,'String',handles.DataScale(2));
guidata(hObject,handles);
set(gca,'Xlim',[x(1) x(2)]);

redraw_all_slices(hObject, eventdata, handles);
guidata(hObject, handles);

function limit_down_Callback(hObject, eventdata, handles)
% hObject    handle to limit_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limit_down as text
%        str2double(get(hObject,'String')) returns contents of limit_down as a double


% --- Executes during object creation, after setting all properties.
function limit_down_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limit_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function limit_up_Callback(hObject, eventdata, handles)
% hObject    handle to limit_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limit_up as text
%        str2double(get(hObject,'String')) returns contents of limit_up as a double


% --- Executes during object creation, after setting all properties.
function limit_up_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limit_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setmanual_histogram.
function setmanual_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to setmanual_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

min=str2num(get(handles.limit_down,'String'));
max=str2num(get(handles.limit_up,'String'));
handles.DataScale=[min max];
guidata(hObject,handles);
set(handles.histogram,'Xlim',[min max]);

redraw_all_slices(hObject, eventdata, handles);
guidata(hObject, handles);

function new_line_Callback(hObject, eventdata, handles)

handles.lines.index = handles.lines.index + 1;

guidata(hObject, handles);


% --- Executes on button press in subvol_select.
function subvol_select_Callback(hObject, eventdata, handles)
% hObject    handle to subvol_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

unset_callbacks(hObject, eventdata, handles);

handles.subvol.data = [];

guidata(hObject,handles);

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions

x = 0;
y = 0;
z = 0;
z2 = 0;
fy2 = 0;
fx2 = 0;

orientation = get(gco,'Tag');

if orientation == 'xy_image'
	x = [p1(1) p1(1)+offset(1)];
	y = [p1(2) p1(2)+offset(2)];
	x=round(x);
	y=round(y);
	
	rectangle('Position',[x(1) y(1) abs(x(2) - x(1)) abs(y(2) - y(1))],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect','Parent',gca);
	axes(handles.axes.xz);
	line('Xdata',[x(1) x(2)],'Ydata',[handles.position.xy handles.position.xy],'LineWidth',1,'Color',[0 1 0]);
	axes(handles.axes.yz);
	line('Xdata',[handles.position.xy handles.position.xy],'Ydata',[y(1) y(2)],'LineWidth',1,'Color',[0 1 0]);

	while (strcmp(get(gco,'Tag'),'xz_image') == false & strcmp(get(gco,'Tag'),'yz_image') == false)
				
		k = waitforbuttonpress; %waiting for the 1st point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    		
			pt = point1(1,1:2);
    			x1=pt(1)*100;y1=pt(2)*100;
    			x1=round(x1)/100;y1=round(y1)/100;
    			if get(gco,'Tag') == 'yz_image'
				y1 = ((y(2) - y(1)) / 2) + y(1);
				h=drawmark(x1,y1);
				z1 = round(x1);
			elseif get(gco,'Tag') == 'xz_image'
				x1 = ((x(2) - x(1)) / 2) + x(1);
				h=drawmark(x1,y1);
				z1 = round(y1);
			end
				
		
		end
		lastfig = get(gco, 'Tag');
	end
	
	while (z2 == 0)
		
		k = waitforbuttonpress;%waiting for the 2nd point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    			pt = point1(1,1:2);
    			x2=pt(1)*100;y2=pt(2)*100;
    			x2=round(x2)/100;y2=round(y2)/100;
    			%drawmark(x2,y2);
					
			if (strcmp(get(gco,'Tag'),'yz_image') == true & strcmp(lastfig,'yz_image') == true)
				z2 = round(x2);
			elseif (strcmp(get(gco,'Tag'),'xz_image') == true & strcmp(lastfig,'xz_image') == true)
				z2 = round(y2);
			end
			
		end
	
	end

	if z1 < z2
		z = [z1 z2];
	else
		z = [z2 z1];
	end
			
elseif orientation == 'xz_image'
	x = [p1(1) p1(1)+offset(1)];
	z = [p1(2) p1(2)+offset(2)];
	x=round(x);
	z=round(z);
	
	rectangle('Position',[x(1) z(1) abs(x(2) - x(1)) abs(z(2) - z(1))],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect','Parent',gca);
	axes(handles.axes.xy);
	line('Xdata',[x(1) x(2)],'Ydata',[handles.position.xz handles.position.xz],'LineWidth',1,'Color',[0 1 0]);
	axes(handles.axes.yz);
	line('Xdata',[z(1) z(2)],'Ydata',[handles.position.xz handles.position.xz],'LineWidth',1,'Color',[0 1 0]);

	while (strcmp(get(gco,'Tag'),'xy_image') == false & strcmp(get(gco,'Tag'),'yz_image') == false)
				
		k = waitforbuttonpress; %waiting for the 1st point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    		
			pt = point1(1,1:2);
    			x1=pt(1)*100;y1=pt(2)*100;
    			x1=round(x1)/100;y1=round(y1)/100;
    			if get(gco,'Tag') == 'xy_image'
				x1 = ((x(2) - x(1)) / 2) + x(1);
				h=drawmark(x1,y1);
				fy1 = round(y1);
			elseif get(gco,'Tag') == 'yz_image'
				x1 = ((z(2) - z(1)) / 2) + z(1);
				h=drawmark(x1,y1);
				fy1 = round(y1);
			end
				
		
		end
		lastfig = get(gco, 'Tag');
	end
	
	while (fy2 == 0)
		
		k = waitforbuttonpress;%waiting for the 2nd point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    			pt = point1(1,1:2);
    			x2=pt(1)*100;y2=pt(2)*100;
    			x2=round(x2)/100;y2=round(y2)/100;
    			%drawmark(x2,y2);
					
			if (strcmp(get(gco,'Tag'),'xy_image') == true & strcmp(lastfig,'xy_image') == true)
				fy2 = round(y2);
			elseif (strcmp(get(gco,'Tag'),'yz_image') == true & strcmp(lastfig,'yz_image') == true)
				fy2 = round(y2);
			end
			
		end
	
	end
	
	if fy1 < fy2
		y = [fy1 fy2];
	else
		y = [fy2 fy1];
	end
	
	
elseif orientation == 'yz_image'
	z = [p1(1) p1(1)+offset(1)];
	y = [p1(2) p1(2)+offset(2)];
	z=round(z);
	y=round(y);
	
	rectangle('Position',[z(1) y(1) abs(z(2) - z(1)) abs(y(2) - y(1))],'Edgecolor',[0 1 0], 'Linewidth',1,'Tag','subvol_rect','Parent',gca);
	axes(handles.axes.xy);
	line('Xdata',[handles.position.yz handles.position.yz],'Ydata',[y(1) y(2)],'LineWidth',1,'Color',[0 1 0]);
	axes(handles.axes.xz);
	line('Xdata',[handles.position.yz handles.position.yz],'Ydata',[z(1) z(2)],'LineWidth',1,'Color',[0 1 0]);

	while (strcmp(get(gco,'Tag'),'xy_image') == false & strcmp(get(gco,'Tag'),'xz_image') == false)
				
		k = waitforbuttonpress; %waiting for the 1st point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    		
			pt = point1(1,1:2);
    			x1=pt(1)*100;y1=pt(2)*100;
    			x1=round(x1)/100;y1=round(y1)/100;
    			if get(gco,'Tag') == 'xy_image'
				y1 = ((y(2) - y(1)) / 2) + y(1);
				h=drawmark(x1,y1);
				fx1 = round(x1);
			elseif get(gco,'Tag') == 'xz_image'
				y1 = ((y(2) - y(1)) / 2) + y(1);
				h=drawmark(x1,y1);
				fx1 = round(x1);
			end
				
		
		end
		lastfig = get(gco, 'Tag');
	end
	
	while (fx2 == 0)
		
		k = waitforbuttonpress;%waiting for the 2nd point
		if k==0 %mouse button press
    			point1=get(gca,'Currentpoint');
    			pt = point1(1,1:2);
    			x2=pt(1)*100;y2=pt(2)*100;
    			x2=round(x2)/100;y2=round(y2)/100;
    			%drawmark(x2,y2);
					
			if (strcmp(get(gco,'Tag'),'xy_image') == true & strcmp(lastfig,'xy_image') == true)
				fx2 = round(x2);
			elseif (strcmp(get(gco,'Tag'),'xz_image') == true & strcmp(lastfig,'xz_image') == true)
				fx2 = round(x2);
			end
			
		end
	
	end
	
	if fx1 < fx2
		x = [fx1 fx2];
	else
		x = [fx2 fx1];
	end
	
end


handles.subvol.data = [x y z];

guidata(hObject,handles);

redraw_all_slices(hObject, eventdata, handles);

set_callbacks(hObject, eventdata, handles);
guidata(hObject,handles);



% --- Executes on button press in subvol_save.
function subvol_save_Callback(hObject, eventdata, handles)
% hObject    handle to subvol_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subvol = handles.Volume.Value(handles.subvol.data(1):handles.subvol.data(2),handles.subvol.data(3):handles.subvol.data(4),handles.subvol.data(5):handles.subvol.data(6));
tom_emwrite(subvol);
clear subvol;
handles.subvol.data = [];
guidata(hObject,handles);
redraw_all_slices(hObject, eventdata, handles);

% --- Executes on button press in subvol_clear.
function subvol_clear_Callback(hObject, eventdata, handles)
% hObject    handle to subvol_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.subvol.data = [];
guidata(hObject, handles);
redraw_all_slices(hObject, eventdata, handles);
guidata(hObject, handles);


% ----------- Function drawmark -----------
function h=drawmark(x,y)
% DRAWMARK draw a circle and a cross to represent the marker 
%   
%   Syntax: drawmark
%       Input:
%           -x: coordinate x
%           -y: coordinate y
%           -i: text to print (must be a string)
%       Output:
%           - 
%   Date: 09/04/03 WDN  

hold on;
Center= x + y*sqrt(-1);
Radius = 5;Gridpt = 100;
[u,v]=circle(Center,Radius,Gridpt);
%line(u,v,'LineWidth',1,'Color',[1 0 0]);
uu = [x x x x-Radius x+Radius];
vv = [y-Radius y+Radius y y y];
h=line(uu,vv,'LineWidth',1,'color',[0 1 0]);

hold off;

% ----------- Function setmark_circle -----------
function [X, Y] = circle(w,r,n)
%CIRCLE is used to calculate the coordinate of a circle.
%
%   Syntax: [X,Y]=circle(w,r,n)
%       Input:
%           w: Center of the circle. W must be a complex number as w=x + yi 
%              (x and y are the coordinate)
%           r: Radius of the circle
%           n: The width of the line         
%       Output:
%           X: it is a matrix of coordinate to draw the circle
%           Y: it is a matrix of coordinate to draw the circle

 w1 = real(w);
 w2 = imag(w);
        for k = 1:n
           t = k*pi/n;
           X(k) = w1 + r*cos(t);
           Y(k) = w2 + r*sin(t);
           X(n+k) = w1 - r*cos(t);
           Y(n+k) = w2 - r*sin(t);
           X(2*n+1) = X(1);
           Y(2*n+1) = Y(1);
         end
