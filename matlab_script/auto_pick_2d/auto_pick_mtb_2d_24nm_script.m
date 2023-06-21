%-------------------------------------------------------------------------------
% Script: auto_pick_mtb_2d_script
% @purpose read x3d coordinate file, picking with specified periodicity & write new file
% @date 20091118
%-------------------------------------------------------------------------------

% Input (Uncomment if you want to use for individual file)
%input_file = 'test_y.crd'; 

% Output
output_file = [regexprep(input_file, '.crd$', '') '_fitted.crd'];

% Parameters
pixel_size = 0.223; % nm
radius = 291;
radius_bad = 50;
final_d = 582;
extract_d = 590;
final_mean = 127;
final_stddev = 40;
period = 24; % nm
dim = 2; % default interplolating dim is y

% Fitting
crd = read_x3d_crd(input_file);

% Deciding dimension to fit (=> sorted dim is exactly as dim)
sorted_dim = sort(crd.DATA(:, dim));
if ~(sum(abs(sorted_dim - crd.DATA(:, dim))) == 0 || sum(abs(flipud(sorted_dim) - crd.DATA(:, dim))) == 0)
	dim = 1;
end
	
new_origins = pick_mtb_2d(crd.DATA, period/pixel_size, dim);

fitted_crd = crd;
% Changing header
fitted_crd.HEADER.OUTFILE_PREFIX = ['''' regexprep(output_file, '.crd$', '') ''''];
fitted_crd.HEADER.RADIUS = num2str(radius);
fitted_crd.HEADER.RADIUS_BAD = num2str(radius_bad);
fitted_crd.HEADER.EXTRACT_DX = num2str(extract_d);
fitted_crd.HEADER.EXTRACT_DY = num2str(extract_d);
fitted_crd.HEADER.FINAL_DX = num2str(final_d);
fitted_crd.HEADER.FINAL_DY = num2str(final_d);
fitted_crd.HEADER.FINAL_MEAN = num2str(final_mean);
fitted_crd.HEADER.FINAL_STDDEV = num2str(final_stddev);
fitted_crd.HEADER.ANGSTROMS = num2str(pixel_size*10);

fitted_crd.DATA = round(new_origins);

% Plotting to check
%plot(new_origins(:,1), new_origins(:,2), 'ro')
%axis([1 2000 1 2000 1 300]);
%view(10, 80);
%box

write_x3d_crd(fitted_crd, output_file);



