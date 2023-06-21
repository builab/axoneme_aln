function bstar = parse_star_file(starFile, parameter)
% PARSE_STAR_FILE parse bsoft star file (1.3 & 1.6 version)
% 	bstar = parse_star_file(starFile, parameter);
% Parameters
%  IN
%	starFile star file to parse
%	parameter 'origin' to retrieve only origin of the picked particles
%  OUT
%	bstar a structure containing the star file content
%	bstar the Nx3 array if 'origin' parameter is used
%
% HB 20080201
% 20080301 change completely, much faster & accurate
% 20080729 can deal with star with bad radius info
% 20100614 make compatible with 1.3 and 1.6 and read into structure & convert to 1.6 format

isHeader = 1;
isData = 1;
bstar.DATA = [];
bstar.DATA_BAD = [];
bstar.VERSION = '';
bstar.HEADER = {};

if exist(starFile, 'file')
    fid = fopen(starFile, 'rt');    
else
    error 'Cannot open file';
end

i = 1;
j = 1;

while (1) 
    tline = fgetl(fid); 
    if ~ischar(tline)
        break;
    end
    if strcmp(tline,'') 
        %disp('Blank')
        continue;
    end
    if ~isempty(regexp(tline, '^\s+$', 'match')) % blank line 
        %disp('Blank')
		continue;
    end
    if ~isempty(regexp(tline, '^#', 'match'))
        %disp('Comment')
        continue;
    end
    if ~isempty(regexp(tline, '^data_', 'match'))
         bstar.NAME = strtrim(regexprep(tline, '^data_', ''));
         continue;
    end
    
    while (isHeader) 

        if ~isempty(regexp(tline, '^\s+$', 'match')) || strcmp(tline, '')% blank line               
            isHeader = 0;   
    		continue;
        end
        
        header_var = regexp(tline, '\s+', 'split');
        
        if isempty(bstar.VERSION)             
            if isempty(regexp(header_var{1}, '_map.3D_reconstruction', 'match'))
                bstar.VERSION = '1.3';
            else
                bstar.VERSION = '1.6';
            end
        end
        bstar.HEADER{i}{1} = strtrim(header_var{1});
        bstar.HEADER{i}{2} = strtrim(header_var{2});
        i = i + 1;
        tline = fgetl(fid);
    end
    
    if ~isempty(regexp(tline, '^loop_', 'match'))
        if isData == 1                
            while (isData)
                tline = fgetl(fid);
                if ~ischar(tline)
                    break;
                end
                if ~isempty(regexp(tline, '^\s+$', 'once')) || strcmp(tline, '')% blank line        
                    isData = 0;
                	continue;
                end
                if ~isempty(regexp(tline, '^_particle', 'match'))                    
                    bstar.PARTICLEHEADER{j} = tline;
                    j = j + 1;
                    continue;
                end
                if ~isempty(regexp(tline, '^\s*\d+\s+([0-9\.])+', 'match'))
                    points = str2num(tline);
            		bstar.DATA = [bstar.DATA; points];			
                end
                
            end
        else % bad data start
            while (1) 
                tline = fgetl(fid);
                if ~ischar(tline)
                    break;
                end
                if ~isempty(regexp(tline, '^\s+$', 'once')) % blank line        
                    isData = 0;
                	continue;
                end
                if ~isempty(regexp(tline, '^_particle', 'match'))
                    continue;
                end
                if ~isempty(regexp(tline, '^\s*([0-9\.])+', 'match'))                    
                    points = str2num(tline);
                    bstar.DATA_BAD = [bstar.DATA_BAD; points];
                end              
            end
        end
    end       
end

fclose(fid);


if strcmp(bstar.VERSION, '1.3')
    bstar = convert_to_bstar1_6(bstar);
end

if nargin == 2
	switch parameter
		case 'origin'
			bstar = bstar.DATA(:,5:7);
		otherwise
	end
end

function bstar1_6 = convert_to_bstar1_6(bstar)
    bstar1_6.VERSION = '1.6';
    bstar1_6.NAME = bstar.NAME;
    bstar1_6.PARTICLEHEADER = {'_particle.id', '_particle.group_id', '_particle.defocus', '_particle.magnification', '_particle.x', ...
                         '_particle.y', '_particle.z', '_particle.origin_x', '_particle.origin_y',  '_particle.origin_z', ...     
                         '_particle.view_x', '_particle.view_y', '_particle.view_z', '_particle.view_angle',  '_particle.fom', '_particle.select'};
    bstar1_6.DATA_BAD = bstar.DATA_BAD;
    data = bstar.DATA;
    nopart = size(data, 1);
    bstar1_6.DATA = [data(:,1) ones(nopart, 1) zeros(nopart, 1) data(:,2:end)];
    bstar1_6.HEADER = {{'_map.3D_reconstruction.id', 'tomo.rec'},...
                 {'_map.3D_reconstruction.file_name', 'tomo.rec.mrc'} ,...
                 {'_map.3D_reconstruction.select', '1'} ,...
                 {'_map.3D_reconstruction.fom', '0.000000'},...
                 {'_map.3D_reconstruction.origin_x', '0.000'},...
                 {'_map.3D_reconstruction.origin_y', '0.000'},...
                 {'_map.3D_reconstruction.origin_z', '0.000'},...
                 {'_map.3D_reconstruction.scale_x', '1.000'},...
                 {'_map.3D_reconstruction.scale_y', '1.000'},...
                 {'_map.3D_reconstruction.scale_z', '1.000'},...
                 {'_map.3D_reconstruction.voxel_size', '1.000'},...
                 {'_particle.box_radius_x', '50.0000'},...
                 {'_particle.box_radius_y', '50.0000'},...
                 {'_particle.box_radius_z', '50.0000'},...
                 {'_particle.bad_radius', '20.0000'},...
                 {'_filament.width', '40.000'},...
                 {'_filament.node_radius', '10.0000'},...
                 {'_refln.radius', '0.000000'},...
                 {'_marker.radius','10.000000'},...
                 {'_map.view_x','0.000000'},...
                 {'_map.view_y','0.000000'},...
                 {'_map.view_z','0.000000'},...
                 {'_map.view_angle','0.000000'}
                 };
   for indx = 1:size(bstar.HEADER, 2)
       switch strtrim(bstar.HEADER{indx}{1})
           case '_micrograph.id'
                bstar1_6.HEADER{1}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.file_name'
                bstar1_6.HEADER{2}{2} = bstar.HEADER{indx}{2};
           case  '_micrograph.x_scale'
                bstar1_6.HEADER{8}{2} = bstar.HEADER{indx}{2};        
           case '_micrograph.y_scale'
                bstar1_6.HEADER{9}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.z_scale'
                bstar1_6.HEADER{10}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.pixel_size'
                bstar1_6.HEADER{11}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.box_radius_x'
                bstar1_6.HEADER{12}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.box_radius_y'
                bstar1_6.HEADER{13}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.box_radius_z'
                bstar1_6.HEADER{14}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.bad_radius'
               bstar1_6.HEADER{15}{2} = bstar.HEADER{indx}{2};
           case '_micrograph.filament_width'
               bstar1_6.HEADER{16}{2} = bstar.HEADER{indx}{2}; 
           case '_micrograph.filament_node_radius'
               bstar1_6.HEADER{17}{2} = bstar.HEADER{indx}{2};    
           case '_micrograph.marker_radius'
               bstar1_6.HEADER{19}{2} = bstar.HEADER{indx}{2};                                  
       end
   end
end
end
