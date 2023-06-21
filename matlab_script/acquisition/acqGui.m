function varargout = acqGui(varargin)
% ACQGUI M-file for acqGui.fig
%      ACQGUI, by itself, creates a new ACQGUI or raises the existing
%      singleton*.
%
%      H = ACQGUI returns the handle to a new ACQGUI or the handle to
%      the existing singleton*.
%
%      ACQGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQGUI.M with the given input arguments.
%
%      ACQGUI('Property','Value',...) creates a new ACQGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before acqGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to acqGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help acqGui

% Last Modified by GUIDE v2.5 18-Mar-2009 11:23:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @acqGui_OpeningFcn, ...
                   'gui_OutputFcn',  @acqGui_OutputFcn, ...
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


% --- Executes just before acqGui is made visible.
function acqGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to acqGui (see VARARGIN)

% Choose default command line output for acqGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Setting the current mode
magTable = load('MagTable.txt');
setappdata(gcf, 'MagTable', magTable);
% Update the guide
mode = {'search', 'focus', 'exposure'};
for i = 1:length(mode)
    set(findobj('Tag', [mode{i} 'Popupmenu']), 'String', num2str(magTable(:,1)));
    updateMag(mode{i});
end

setappdata(gcf, 'ccdPixelSize', 14);
setappdata(gcf, 'currMode', 'search');
setappdata(gcf, 'exposureTime', .5);
activateMode(getappdata(gcf, 'currMode'));
set(findobj('Tag', 'searchImageAxe'), 'XTick', [], 'YTick', []);
set(gca, 'ButtonDownFcn', @(hObject, eventdata) searchImageAxes_ButtonDownFcn)
setappdata(gcf, 'focusPoint', []);
setappdata(gcf, 'exposurePoint', []);
setappdata(gcf, 'searchPoint', []);
setappdata(gcf, 'searchImageDim', 512);
searchImageDim = getappdata(gcf, 'searchImageDim');
focusImageDim = calcRelativeDimension(getMagnification('search'), getMagnification('focus'), searchImageDim);
exposureImageDim = calcRelativeDimension(getMagnification('search'), getMagnification('exposure'), searchImageDim);
setappdata(gcf, 'searchBin', 4);
setappdata(gcf, 'focusBin', 2);
setappdata(gcf, 'exposureBin', 1)
setappdata(gcf, 'focusImageDim', round(focusImageDim));
setappdata(gcf, 'exposureImageDim', round(exposureImageDim));

% Read current Mode from Microscope


% UIWAIT makes acqGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = acqGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in searchButton.
function searchButton_Callback(hObject, eventdata, handles)
% hObject    handle to searchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activateMode('search');
updateMag('search');
axes_redraw();


% --- Executes on button press in focusButton.
function focusButton_Callback(hObject, eventdata, handles)
% hObject    handle to focusButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activateMode('focus');
updateMag('focus');
axes_redraw();

% --- Executes on button press in exposureButton.
function exposureButton_Callback(hObject, eventdata, handles)
% hObject    handle to exposureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activateMode('exposure');
updateMag('exposure');
axes_redraw();


function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to exposureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(gcf, 'exposurePoint', []);
setappdata(gcf, 'focusPoint', []);
axes_redraw();

% --- Executes on button press in  acquireButton.
function acquireButton_Callback(hObject, eventdata, handles)
% hObject    handle to acquireButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currMode = getappdata(gcf, 'currMode');

switch currMode
    case 'search'
        disp(['Acquire image in SEARCH mode with exposure time ' num2str(getappdata(gcf, 'AcqExposureTime'))]);
        im = imread('search.tif');
        setappdata(gcf, 'searchImage', im);
        loadSearchImage(im);
    case 'focus'
        if isempty(getappdata(gcf, 'focusPoint'))
            disp('No focus area is chosen')
            return;
        end
        [filename, pathname] = uiputfile({'*.mrc';'*.*'}, 'Save as MRC-file');
        %Acq image
        %Display image
        im = getappdata(gcf, 'searchImage'); % Simulation
        h = figure(), imagesc(im), title('Focus Image'); colormap gray;axis image;
        %tom_mrcwrite([pathname '/' filename], im);
        disp(['Writing focus image as ' filename])
    case 'exposure'
        exposurePoint = getappdata(gcf, 'exposurePoint');
        if isempty(exposurePoint)
            disp('No focus area is chosen')
            return;
        end
        [filename, pathname] = uiputfile({'*.mrc';'*.*'}, 'Enter Exposure Series Name');
        filePrefix = regexprep(filename, '\.mrc', '');
        % Acq image
        im = getappdata(gcf, 'searchImage'); % Simulation
        h = figure();   title('Exposure Image');
        [m, n] = calcOptimalDimension(size(exposurePoint, 1));
        for i = 1:size(exposurePoint, 1)
            subplot(m, n, i);
            imagesc(im), colormap gray;axis image;
            %tom_mrcwrite([pathname '/' filePrefix '_' sprintf('%0.3d', i) '.mrc'], im)
            disp(['Writing exposure image ' num2str(i) ' as ' filePrefix '_' sprintf('%0.3d', i) '.mrc'])
        end
        % Display image
end

% --- Executes on button press in deleteButton.
function deleteButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch getappdata(gcf, 'currMode')
    case 'exposure'
        exposurePoint = getappdata(gcf, 'exposurePoint');
        if (size(exposurePoint, 1) > 1)
            setappdata(gcf, 'exposurePoint', exposurePoint(1:end-1,:));
        elseif (size(exposurePoint, 1) == 1)
            setappdata(gcf, 'exposurePoint', []);
        end
        
    case 'focus'
        setappdata(gcf, 'focusPoint', []);        
end

axes_redraw();

function searchExposureTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to searchExposureTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of searchExposureTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of searchExposureTimeEdit as a double

setappdata(gcf, 'searchExposureTime', str2double(get(hObject, 'String')));
disp(['Search exposure time is now ' get(hObject, 'String') 's'])



function focusExposureTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to focusExposureTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of focusExposureTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of
%        focusExposureTimeEdit as a double
setappdata(gcf, 'focusExposureTime', str2double(get(hObject, 'String')));
disp(['Focus exposure time is now ' get(hObject, 'String') 's'])


function exposureExposureTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to exposureExposureTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposureExposureTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of exposureExposureTimeEdit as a double
setappdata(gcf, 'acqExposureTime', str2double(get(hObject, 'String')));
disp(['Exposure exposure time is now ' get(hObject, 'String') 's'])

function activateMode(mode)
% activate the selection mode
currMode = getappdata(gcf, 'currMode');
set(findobj('Tag', [currMode 'Button']), 'BackgroundColor', [0.702 0.702 0.702]);
set(findobj('Tag', [mode 'Button']), 'BackgroundColor', 'yellow');
setappdata(gcf, 'currMode', mode);
disp([upper(mode) ' is activated'])

function updateMag(mode)
% updateMagnification at the gui
currMag = getMagnification(mode);
setappdata(gcf, [mode 'Magnification'], currMag);    
magTable = getappdata(gcf, 'MagTable');
[realMag, indx] = realMagLookup(currMag, magTable);
set(findobj('Tag', [mode 'Popupmenu']), 'Value', indx);   


function loadMag(popupHandles, magTable)
% updateMagnification at the gui
set(popupHandles, 'String', num2str(magTable(:,1)));

function loadSearchImage(im)

if ~isempty(im)
% load image in search mode
    [m, n] = size(im);
    im_red = imresize(im, [512 512]);
    [meanv max min std]= tom_dev(im_red);

    hold on
    if (meanv-4*std)>=(meanv+4*std)
        h = imagesc(im_red);
    else
        h = imagesc(im_red,[meanv-4*std meanv+4*std]);
        colormap gray;axis image;
    end;
    colormap gray; 
    set(findobj('Tag', 'searchImageAxe'), 'XTick', [0 256 512], 'YTick', [0 256 512]);
    set(h,'HitTest','off')
    hold off
    set(gca, 'ButtonDownFcn', @(hObject, eventdata) searchImageAxes_ButtonDownFcn)
end

function drawRectangle(origins, width, height, style)
% drawing rectangle (array)

for i = 1:size(origins, 1)
    lowerX = origins(i, 1)-floor(width/2);
    upperX = origins(i, 1)+floor(width/2)-1;
    lowerY = origins(i, 2)-floor(height/2);
    upperY = origins(i, 2)+floor(height/2)-1;
    if lowerX < 0
        lowerX = 0;
    end
    if upperX > getappdata(gcf, 'searchImageSize')
        upperX = getappdata(gcf, 'searchImageSize');
    end
    if lowerY < 0
        lowerY = 0;
    end
    if upperY > getappdata(gcf, 'searchImageSize')
        upperY = getappdata(gcf, 'searchImageSize');
    end
    x = lowerX:1:upperX;
    y = lowerY:1:upperY;

    h = plot(x, ones(length(x), 1)*(origins(i, 2)-floor(height/2)), style);
    set(h, 'HitTest', 'off');
    h = plot(x, ones(length(x), 1)*(origins(i, 2)+floor(height/2)-1), style);
    set(h, 'HitTest', 'off');
    h = plot(ones(length(y), 1)*(origins(i, 1)-floor(width/2)), y, style);
    set(h, 'HitTest', 'off');
    h = plot(ones(length(y), 1)*(origins(i, 1)+floor(width/2)-1), y, style);
    set(h, 'HitTest', 'off');
end

function searchImageAxes_ButtonDownFcn(hObject, eventdata, handles)

currPoint = get(gca, 'CurrentPoint');
oriX = currPoint(1,1);
oriY = currPoint(1,2);

switch getappdata(gcf, 'currMode')
    case 'search'
        disp(['X = ' num2str(oriX) ' Y = ' num2str(oriY)]);
        setappdata(gcf, 'searchPoint', [oriX oriY]);
        axes_redraw();  
    case 'focus'
        disp(['X = ' num2str(oriX) ' Y = ' num2str(oriY)]);
        setappdata(gcf, 'focusPoint', [oriX oriY]);
        axes_redraw();        
    case 'exposure'
        disp(['X = ' num2str(oriX) ' Y = ' num2str(oriY)]);
        exposurePoint = getappdata(gcf, 'exposurePoint');
        exposurePoint = [exposurePoint; oriX oriY];
        setappdata(gcf, 'exposurePoint', exposurePoint);        
        axes_redraw();
end

function axes_redraw

cla;

im = getappdata(gcf, 'searchImage');

switch getappdata(gcf, 'currMode')
    case 'search'       
        loadSearchImage(im);
        searchPoint = getappdata(gcf, 'searchPoint');
        searchImageDim = round(getappdata(gcf, 'searchImageDim')/10);
        hold on
        drawRectangle(searchPoint, searchImageDim, searchImageDim, 'r-');
        hold off
    case 'focus'
        loadSearchImage(im);
        focusPoint = getappdata(gcf, 'focusPoint');
        focusImageDim = getappdata(gcf, 'focusImageDim');
        hold on
        drawRectangle(focusPoint, focusImageDim, focusImageDim, 'y-');
        hold off
    case 'exposure'
        loadSearchImage(im); 
        exposurePoint = getappdata(gcf, 'exposurePoint');
        exposureImageDim = getappdata(gcf, 'exposureImageDim');
        hold on
        drawRectangle(exposurePoint, exposureImageDim, exposureImageDim, 'y-');
        hold off
end


function relSize = calcRelativeDimension(refMag, calcMag, refSize)
magTable= getappdata(gcf, 'MagTable');
[realRefMag, indx] = realMagLookup(refMag, magTable);
[realCalcMag, indx] = realMagLookup(calcMag, magTable);
relSize = realRefMag/realCalcMag*refSize;


function [realMag, indx] = realMagLookup(mag, magTable)
% Look up real mag in a magTable
for indx = 1:size(magTable, 1)
    if magTable(indx, 1) == mag
        realMag = magTable(indx, 2);        
        break;
    end
end
   

% --- Executes on button press in moveSearchButton.
function moveSearchButton_Callback(hObject, eventdata, handles)
% hObject    handle to moveSearchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(getappdata(gcf, 'currMode'), 'search') < 1
    disp ('Only work in Search mode')    
    return;
end

if isempty(getappdata(gcf, 'searchPoint'))
    disp('No new destination is selected')
    return;
end

% Move to new place
distance = getappdata(gcf, 'searchPoint') - floor(getappdata(gcf, 'searchImageDim')/2)
searchMag = realMagLookup(getMagnification('search'), getappdata(gcf, 'MagTable'));
distance = distance*getappdata(gcf, 'searchBin')*getappdata(gcf, 'ccdPixelSize')/searchMag;
%move_stage_new([distance 0]);
disp(['Move stage to along X ' num2str(distance(1)) ' along Y ' num2str(distance(2))])


% Blank the screen
setappdata(gcf, 'searchImage', []);
setappdata(gcf, 'searchPoint', []);
axes_redraw();

function [m, n] = calcOptimalDimension(numberOfImages)
% Calculate optimal dimension for display image

m = ceil(sqrt(numberOfImages));
n = m;
while (1)
    if m*(n-1) < numberOfImages
        return
    end
    n = n -1;
end


% --- Executes on selection change in searchPopupmenu.
function searchPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to searchPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns searchPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from searchPopupmenu
mode = 'search';
value = get(hObject, 'Value');
magTable = getappdata(gcf, 'MagTable');
newMag = magTable(value, 1);
setappdata(gcf, [mode 'Magnification'], newMag); 
% setMagnification(mode, newMag)
disp(['Change ' upper(mode) ' magnification to ' num2str(newMag)]);

% --- Executes on selection change in focusPopupmenu.
function focusPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to focusPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns focusPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from focusPopupmenu
mode = 'focus';
value = get(hObject, 'Value');
magTable = getappdata(gcf, 'MagTable');
newMag = magTable(value, 1);
setappdata(gcf, [mode 'Magnification'], newMag); 
% setMagnification(mode, newMag)
disp(['Change ' upper(mode) ' magnification to ' num2str(newMag)]);

% --- Executes on selection change in exposurePopupmenu.
function exposurePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to exposurePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns exposurePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from exposurePopupmenu
mode = 'exposure';
value = get(hObject, 'Value');
magTable = getappdata(gcf, 'MagTable');
newMag = magTable(value, 1);
setappdata(gcf, [mode 'Magnification'], newMag); 
% setMagnification(mode, newMag)
disp(['Change ' upper(mode) ' magnification to ' num2str(newMag)]);
