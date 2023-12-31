function tom_convert(varargin)

%    tom_convert(oldext, newext, bin, 'all')
%    TOM_CONVERT converts images to an new format. 
%    if the flag 'all' is set all files of one directory will be
%    transformed. BIN denotes the binningfactor.
%    Possible in- and output formats:
%       'em' 'emx'      (mrc => em works; mrc <= em works not yet!)
%       'mrc'           (FEI- format)
%       'dat'           (Header info is missing; )
%       
%      
%     
%       'tif' or 'tiff' Tagged Image File Format (TIFF)
%       'jpg' or 'jpeg' Joint Photographic Experts Group (JPEG)
%       'bmp'           Windows Bitmap (BMP)
%       'png'           Portable Network Graphics (PNG)
%       'hdf'           Hierarchical Data Format (HDF)
%       'pcx'           Windows Paintbrush (PCX)
%       'xwd'           X Window Dump (XWD)
%
%    Example: tom_convert('em','tiff',2,'all')
% 
%    03/25/04    GS
%
%    Copyright (c) 2004
%    TOM toolbox for Electron Tomography
%    Max-Planck-Institute for Biochemistry
%    Dept. Molecular Structural Biology
%    82152 Martinsried, Germany
%    http://www.biochem.mpg.de/tom

error(nargchk(2,4,nargin));
oldext = ['*.' varargin{1}];
newext = varargin{2};
if ispc == 1; delim = '\';
else; delim = '/'
end
    
if nargin == 2
    [name,path] = uigetfile(oldext,'select an image');
    if name == 0
        return
    end
    bin = 0;
    num = 1;
    all = 0;
elseif nargin == 3
    if strcmp((varargin{3}),'all') ;
        path = uigetdir;
        if path == 0
            return
        end
        path = [path delim];
        cd(path);
        filenames = (dir (oldext));
        num = size(filenames);
        num = num(1);
        all = 1;
        bin = 0;
    else  
        [name,path] = uigetfile(oldext,'select an image');
        if name == 0
            return
        end
        num = 1;
        all = 0;
        bin = varargin{3};
    end    
else
    path = uigetdir;
    if path == 0
        return
    end
    path = [path delim];
    cd(path);
    filenames = (dir (oldext));
    num = size(filenames);
    num = num(1);
    all = 1;
    bin = varargin{3};
end




for ind = 1:num 
    if all == 1
        name = filenames(ind).name;
    end
    newname = name(1:(size(name,2)-size(varargin{1},2)));
    newname = [newname newext];
    %OPEN IMAGES
    if strcmp(varargin{1},'em') || strcmp(varargin{1},'emx')
        im = tom_emread([path name]);
    elseif strcmp(varargin{1},'mrc') 
        im = tom_mrcread([path name]);
    elseif strcmp(varargin{1},'dat')
        im = tom_rawread([path name],'int16','le',[2048 2048 1],1,0);
    else
        im = imread([path name]);
    end
    
    if bin > 0
        if isstruct(im)
            im.Value=tom_bin(im.Value, bin);
        else
            im=tom_bin(im, bin);
        end
    end
    
    %WRITE IMAGES  
    if strcmp(newext,'em')
        tom_emwrite(newname,im)
    elseif strcmp(newext,'mrc')
        tom_mrcwrite(newname,im)
    elseif strcmp(newext,'dat')        
    else
        if isstruct(im)
            im=im.Value;
        end
        im = tom_norm(im',255);
        imwrite(uint8(im), newname, newext)
    end
end