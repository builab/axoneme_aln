function emwrite(cube_name, em_name)
% emwrite -- Matlab cube to EM converter
%
%  Usage:
%    cube2em(cube_name, em_name)
%  Inputs:
%    cube_name    	array including 3-d image
%
%  Outputs:
%    em_name    	3-d image in EM format (V, floating point / char)
%
%  Description
%    
%  See Also
%    emread, emwriteheader
%

% last mod. Alex 2010, commented out the display.
% prepare EM header

%f=sprintf('Writing EM-file: %s',em_name);disp(f);
[xdim,ydim,zdim] = size(cube_name);
fid = fopen(em_name,'w','ieee-le');
if fid==-1, error('Error: Can not write file! Check priorities...'); end;
fwrite(fid,6,'char');
fwrite(fid,0,'char');
fwrite(fid,0,'char');
if(isa(cube_name,'uint8'))
    fwrite(fid,1,'char');
else
    fwrite(fid,5,'char');
end;
fwrite(fid,xdim,'uint32');
fwrite(fid,ydim,'uint32');
fwrite(fid,zdim,'uint32');

for i = 1:496, 
    fwrite(fid,0,'char');
end

% write out data

if(isa(cube_name,'uint8'))
    fwrite(fid,cube_name,'uint8');
else
    fwrite(fid,cube_name,'float');
end;
fclose(fid);
