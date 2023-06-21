%% --------------------------------------------------------------------------
%  Script: plotFlagella.m
%  Purpose: plotting flagella with vanadate and non-nucleotide coloring differently
%  Date: 20081220
%% --------------------------------------------------------------------------

% TODO
% Add text Proximal & Distal end

% ----------- TO CHANGE -----------------------------------------------------

flagellaName = 'ADP_02'
doubletNumber = [1 2 3 4 5 6 8 9];
docPrefix = 'doc_class02_';

% ----------- END CHANGE ----------------------------------------------------

% -----------default variable ---------
docDir = 'doc';
number_of_classes = 2;
pattern = {'yo', 'bo', 'r*'};
% -------------------------------------

for doubletId = doubletNumber
	starFile = [flagellaName '_' num2str(doubletId) '.star'];
	docFile = [docDir '/' docPrefix flagellaName '_' sprintf('%0.3d', doubletId) '.spi'];
    disp(docFile)
	
	% Reading
	%starContent = parse_star_file(starFile);
	docContent = parse_spider_doc(docFile);
 
	phi = docContent(1, 1);
	particleList = [1: size(docContent, 1)];

	if (phi <= 180) && (phi > 0) || (phi < -180) && (phi >= -360)
		particleList = fliplr(particleList);
	end

	% Drawing
	for particleId = 1:size(docContent, 1)
		%disp(pattern{docContent(particleId, 8)});
		plot(particleList(particleId), doubletId, pattern{docContent(particleId, 8)+1}) 	
		hold on
	end
	
end

tit = regexprep(flagellaName, '_', '\\_'); disp(tit)
title(upper(tit),'FontWeight','bold');
xlabel('Particles','FontWeight','bold')
ylabel('Doublet Number','FontWeight','bold')
axis([0 60 0 10])
set(gca, 'ytick', [1:9])
set(gca, 'xtick', [0:10:60])
text(2,9.5,'Proximal','FontWeight','bold')
text(50,9.5,'Distal','FontWeight','bold')
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, '-r0', [flagellaName '_' docPrefix 'plot.tif'], '-dtiff');

