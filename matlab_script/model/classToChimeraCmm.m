%% --------------------------------------------------------------------------
%  Script: classToChimeraCmm.m
%  Purpose: Converting classification data into Chimera cmm file to visualize
%  Date: 20101018
%% --------------------------------------------------------------------------

docPrefix = 'doc_class01_'
flagName = 'wt_van_70';
docDir = 'doc';
starDir = 'star';
markerRadius = 15;
markerColor = {[0 0 1], [0 0 1], [1 0 0]};

for doubletId = 2:9
	starInputFile = [starDir '/' flagName '_' num2str(doubletId) '.star'];
	docInputFile = [docDir '/' docPrefix flagName sprintf('_%0.3d', doubletId) '.spi'];
	disp(starInputFile);
	disp(docInputFile);
	origin = parse_star_file(starInputFile, 'origin');
	transform = parse_spider_doc(docInputFile);
	origin_xform = transform_pts(origin, transform);
	
	% Separate into 3 class
	for classId = 0:2
		class_indx = (transform(:,8) == classId);
		if sum(class_indx) > 0			
			classOrigin = origin_xform(class_indx, :);
			outputCmmFile = [flagName '_' num2str(doubletId) '_c' num2str(classId) '.cmm'];
			disp(['Writing ' outputCmmFile '...']);
			write_chimera_marker(outputCmmFile, classOrigin, [], markerColor{classId + 1}, markerRadius, [flagName '_' num2str(doubletId) '_c' num2str(classId)]);			 
		end
    end
   % Seperate into 2 classes (0 = 1)
end
