function i = write_chimera_marker(markerFile, markers, links, color, radius, setName)
% WRITE_CHIMERA_MARKER write files in Chimera marker file format
%   write_chimera_marker(markerFile, markers, links, color, radius)
% Parameters
%   IN
%       markerFile string of output file name
%       markers Nx3 array contains marker coordinates
%       links Nx2 array contains marker id
%       radius radius of markers
%       color 1x3 array color of markers in rgb
% HB 20100508

if (nargin < 6)
    setName = 'set 1';
end

fid = fopen(markerFile, 'wt');

if fid < 0
    error('Cannot write file');
end

fprintf(fid, '<marker_set name="%s">\n', setName);
for j = 1:size(markers, 1)
     fprintf(fid, '<marker id="%d" x="%5.2f" y="%5.2f" z="%5.2f" r="%4.3f" g="%4.3f" b="%4.3f" radius="%d"/>\n', j, markers(j, 1), markers(j, 2), markers(j, 3), color(1), color(2), color(3), radius);
end
for j = 1:size(links, 1)
    fprintf(fid, '<link id1="%d" id2="%d" r="%4.3f" g="%4.3f" b="%4.3f" radius="%d"/>\n', links(j, 1), links(j, 2), color(1), color(2), color(3), radius);
end
fprintf(fid, '</marker_set>\n');