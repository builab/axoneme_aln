filename = 'test.spi'; % Volume to apply missing wedge
output = 'out.spi'; % Output file name
rot_angle = [30 0 0]; % Rotational angles of the missing wedge

volstr = tom_spiderread2(filename); % read

% Create the missing wedge (type 'help function' to see help
wedge = missing_wedge_3d_arbitrary(size(volstr.data), -95.7, -60, 60, rot_angle);

% View the wedge
tom_dspcub(wedge, 0)

% Apply the missing wedge
vol_new = ifftn(fftn(volstr.data).*ifftshift(wedge), 'symmetric');


% Write out as a SPIDER file format
tom_spiderwrite2(output, vol_new);
