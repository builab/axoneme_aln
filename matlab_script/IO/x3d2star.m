function x3d2star(x3dStruct, outputBstar)
% X3D2STAR converts x3d data into bstar data
% 		x3d2star(x3dStruct, outputBstar)
% HB 2012/06/08

% Printing header
fid = fopen(outputBstar, 'wt');

fprintf(fid, '#%s\n\n', date);
fprintf(fid, 'data_40\n\n');
fprintf(fid, '%-42s%d\n', '_micrograph.field_id', 1);
fprintf(fid, '%-42s%d\n', '_micrograph.id', 1);
fprintf(fid, '%-42s%d\n', '_micrograph.number', 0);
fprintf(fid, '%-42s%d\n', '_micrograph.select', 1);
fprintf(fid, '%-42s%s\n', '_micrograph.fom', '0.0000');
fprintf(fid, '%-42s%s\n', '_micrograph.file_name', x3dStruct.HEADER.PIC_FILENAME);
fprintf(fid, '%-42s%s\n','_micrograph.magnification','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.sampling','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.pixel_size','1.000000');
fprintf(fid, '%-42s%s\n','_micrograph.electron_dose','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.tilt_axis','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.tilt_angle','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.level_angle','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.rotation_angle','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.origin_x','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.origin_y','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.origin_z','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.scale_x','1.000000');
fprintf(fid, '%-42s%s\n','_micrograph.scale_y','1.000000');
fprintf(fid, '%-42s%s\n','_micrograph.scale_z','1.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_1_1','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_1_2','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_1_3','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_2_1','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_2_2','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_2_3','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_3_1','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_3_2','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.matrix_3_3','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.h_x','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.h_y','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.h_z','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.k_x','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.k_y','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.k_z','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.l_x','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.l_y','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.l_z','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.helix_axis_angle','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.helix_subunit_rise','0.000000');
fprintf(fid, '%-42s%s\n','_micrograph.helix_subunit_angle','0.000000');
fprintf(fid, '%-42s%s\n','_particle.box_radius_x','200.000000');
fprintf(fid, '%-42s%s\n','_particle.box_radius_y','200.00000');
fprintf(fid, '%-42s%s\n','_particle.box_radius_z','0.000000');
fprintf(fid, '%-42s%s\n','_particle.bad_radius','175.000000');
fprintf(fid, '%-42s%s\n','_filament.width','40.000000');
fprintf(fid, '%-42s%s\n','_filament.node_radius','10.000000');
fprintf(fid, '%-42s%s\n','_refln.radius','0.000000');
fprintf(fid, '%-42s%s\n','_marker.radius','10.000000');

fprintf(fid,'\nloop_\n');
fprintf(fid,'_particle.id\n');
fprintf(fid,'_particle.group_id\n');
fprintf(fid,'_particle.defocus\n');
fprintf(fid,'_particle.magnification\n');
fprintf(fid,'_particle.x\n');
fprintf(fid,'_particle.y\n');
fprintf(fid,'_particle.z\n');
fprintf(fid,'_particle.origin_x\n');
fprintf(fid,'_particle.origin_y\n');
fprintf(fid,'_particle.origin_z\n');
fprintf(fid,'_particle.view_x\n');
fprintf(fid,'_particle.view_y\n');
fprintf(fid,'_particle.view_z\n');
fprintf(fid,'_particle.view_angle\n');
fprintf(fid,'_particle.fom\n');
fprintf(fid,'_particle.select\n');

for i = 1:size(x3dStruct.DATA, 1)
    fprintf(fid, '%4d %5d %5d %5.4f %7.2f %7.2f %7.2f %6.3f %6.3f %6.3f %6.4f %6.4f %6.4f %6.2f %6.4f %2d\n', i, 1, 0, 1, x3dStruct.DATA(i, 1), x3dStruct.DATA(i, 2), 0, 200, 200, 0, 0, 0, 1, 0, 1, 1);
end
fprintf(fid, '\n');

if ~isempty(x3dStruct.DATA_BAD)
    fprintf(fid, 'loop_\n_particle.bad_x\n_particle.bad_y\n_particle.bad_z\n');
    for i = 1: size(x3dStruct.DATA_BAD, 1)
        fprintf(fid, '%.2f %.2f %.2f\n', x3dStruct.DATA_BAD(i,1),x3dStruct.DATA_BAD(i,2), 0);
    end
    fprintf(fid, '\n');
end


fclose(fid);
