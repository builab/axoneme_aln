%-------------------------------------------------------------------------------
% Script: auto_pick_mtb_2d_96nm_script
% @purpose read x3d coordinate file, picking with 96nm periodicity & write new file
% @explain pick 4 version 1-4
% @date 20091118
%-------------------------------------------------------------------------------

% Input
%input_file = 'test_y.crd';

% Parameters
pixel_size = 0.223; % nm
radius = 290;
radius_bad = 50;
final_d = 582;
extract_d = 590;
final_mean = 127;
final_stddev = 40;
period = 96; % nm
dim = 2; % default interplolating dim is y
var_no = 4;

% Fitting
crd = read_x3d_crd(input_file);

% Deciding dimension to fit (=> sorted dim is exactly as dim)
sorted_dim = sort(crd.DATA(:, dim));
if ~(sum(abs(sorted_dim - crd.DATA(:, dim))) == 0 || sum(abs(flipud(sorted_dim) - crd.DATA(:, dim))) == 0)
	dim = 1;
	disp('Interpolating along x');
else
	disp('Interpolating along y');
end

new_origins = pick_mtb_2d_ida(crd.DATA, period/pixel_size, dim, var_no);

fitted_crd = crd;
fitted_crd.HEADER.RADIUS = num2str(radius);
fitted_crd.HEADER.RADIUS_BAD = num2str(radius_bad);
fitted_crd.HEADER.EXTRACT_DX = num2str(extract_d);
fitted_crd.HEADER.EXTRACT_DY = num2str(extract_d);
fitted_crd.HEADER.FINAL_DX = num2str(final_d);
fitted_crd.HEADER.FINAL_DY = num2str(final_d);
fitted_crd.HEADER.FINAL_MEAN = num2str(final_mean);
fitted_crd.HEADER.FINAL_STDDEV = num2str(final_stddev);
fitted_crd.HEADER.ANGSTROMS = num2str(pixel_size*10);

for var_ind = 1:var_no
	output_file = [regexprep(input_file, '.crd$', '') '_v' num2str(var_ind) '.crd'];
	fitted_crd.HEADER.OUTFILE_PREFIX = ['''' regexprep(output_file, '.crd$', '') ''''];
	fitted_crd.DATA = round(new_origins{var_ind});
	write_x3d_crd(fitted_crd, output_file);
end

% Plotting to check
%plot(new_origins{1}(:,1), new_origins{1}(:,2), 'ro')
%axis([1 2000 1 2000 1 300]);
%view(10, 80);
%box


