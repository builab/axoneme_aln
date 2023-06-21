function crd = read_x3d_crd(crd_file)
% READ_X3D_CRD read x3d coordinate file
%		crd = read_x3d_crd(crd_file)
% PARAMETERS
%  IN
%   crd_file coordinate file from x3d
%  OUT
%   crd structure from x3d
% HB 2009/11/18
% 2009/11/19 improve to read file with bad radius

crd.HEADER.FILENAME = crd_file;

dataStart = 0;
data = [];
data_bad = [];

if exist(crd_file, 'file')
	fid  = fopen(crd_file, 'rt');
	while (1)
		tline = fgetl(fid);
		if ~ischar(tline) % blank line		
			break;
        end        
		%test = regexp(tline, '\$END', 'once', 'ignorecase');
        %disp(test)
		if dataStart == 0		
			if ~isempty(regexp(tline, '\$TRIMNEWPARAMETERS', 'once', 'ignorecase')) %header start
				continue;
			end			
			if ~isempty(regexp(tline, '\$END', 'once', 'ignorecase')) % header end
				dataStart = 1;
				continue;
            end
            header_var = regexp(tline, '=', 'split');
            crd.HEADER.(strtrim(header_var{1})) = strtrim(regexprep(header_var{2}, '(.*),\s*$', '$1'));
			
		end

		if dataStart == 1 % data part
			%disp(tline);
			data_line = regexp(tline, '^\s*\d+\s+([0-9\.])+', 'match');
			point = str2num(tline);
			if point(1) > 0
				data = [data; point];
			else
				data_bad = [data_bad; point];
			end
		end	
	end	
else
	error('File does not exist');
end

if ~isempty(data)
	crd.DATA = data(:,2:3);
else
	crd.DATA = [];
end

if ~isempty(data_bad)
	crd.DATA_BAD = data_bad(:,2:3);
else
	crd.DATA_BAD = [];
end
