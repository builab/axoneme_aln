function write_imod_ascii(model, asciiFile)
% Write imod model to ascii file
%	 write_imod_point(model, pointFile)
% Parameters
%  IN
%    model	little bit complicated imod model, only open/close/scatter is indicated, no directives for contour
%    asciiFile	output ascii model file
%
% HB 20080719
% NOT YET FINISH !!!!!!!!

if ~isstruct(model)
    error 'Not a structure'
end

fnModel = fieldnames(model);
fid = fopen(asciiFile, 'wt');

% Header
fprintf(fid, 'imod %d\n\n', length(fnModel));

% Don't write any model directive

for objectId = 1:length(fnModel)
    object = model.(fnModel{objectId});
    fnObject = fieldnames(object);

    % Write object directives
    number_of_contours = length(fnObject);
    objectName = '';
    objectColor = '0 1 0 1';
    objectType = 'closed';
    pointSize = '0';
    if isfield(object, 'directives')
        number_of_contours = length(fnObject) - 1;

        if isfield(object.directives, 'name')
            objectName = object.directives.name;
        end

        if isfield(object.directives, 'color')
            objectColor = sprintf('%.1f %.1f %.1f %.1f', object.directives.color);
        end

        if isfield(object.directives, 'type')
            switch object.directives.type
                case 'closed'
                    continue;
                case 'open'
                    objectType = 'open';
                case 'scattered'
                    objectType = sprintf('%s\n%s', 'open', 'scattered');
                otherwise
                    error ('Unknown type flag');
            end
        end

        if isfield(object.directives, 'pointsize')
            pointSize = sprintf('%d', object.directives.pointsize);
        end
    end

    fprintf(fid, 'object %d %d 0\n', objectId-1, number_of_contours);
    fprintf(fid, 'name %s\n', objectName);
    fprintf(fid, 'color %s\n', objectColor);
    fprintf(fid, '%s\n', objectType);
    fprintf(fid, 'pointsize %s\n', pointSize);    
    % default
    fprintf(fid, 'drawmode 1\n');
    fprintf(fid, 'linewidth 1\n');
    fprintf(fid, 'axis 0\n');
    fprintf(fid, 'surfsize 0\n');

    contourId = 0;

    for contourName = fnObject'
        if strcmp(contourName{1}, 'directives')
            %disp('Skip object directives');
            continue;
        end

        contour = object.(contourName{1});
        fprintf(fid, 'contour %d 0 %d\n', contourId, size(contour, 1));
        number_of_points = size(contour,1);
        for pointId = 1:number_of_points
            fprintf(fid, '%.2f %.2f %.2f\n', contour(pointId, 1), contour(pointId, 2), contour(pointId, 3));
        end
        contourId = contourId + 1;
    end
    fprintf(fid, '\n');
end

fclose(fid);
