function write_imod_point(model, pointFile)
% Write imod model to point file
%	 write_imod_point(model, pointFile)
% Parameters
%  IN
%    model	simple imod model, no directive data available
%    pointFile	outputFile
% HB 20080717

if ~isstruct(model)
	error "Not a structure"
end

fnModel = fieldnames(model);
fid = fopen(pointFile, 'wt');

for objectId = 1:length(fnModel)
	object = model.(fnModel{objectId});

	fnObject = fieldnames(object);
	for contourId = 1:length(fnObject)
		contour = object.(fnObject{contourId});
		number_of_points = size(contour,1);
		for pointId = 1:number_of_points
			fprintf(fid, '%10d %10d %10.2f %10.2f %10.2f\n', objectId, contourId, contour(pointId, 1), contour(pointId, 2), contour(pointId, 3));
		end	
	end
end

fclose(fid);
