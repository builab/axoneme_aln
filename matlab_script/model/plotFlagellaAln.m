%% --------------------------------------------------------------------------
%  Script: plotFlagellaAln.m
%  Purpose: plotting flagella with vanadate and non-nucleotide coloring differently with vertical alignment
%  Date: 20081220
%% --------------------------------------------------------------------------

% ----------- TO CHANGE -----------------------------------------------------
%listFile = 'list_wt_van.txt';
%flagellaName = 'ADP31';
%docPrefix = 'doc_class4_';
% ----------- END CHANGE ----------------------------------------------------

% -----------default variable ---------
docDir = 'doc';
number_of_classes = 2;
pattern = {'yo', 'bo', 'r*'};
% -------------------------------------

[mtb_list, number_of_records] = parse_list(listFile);
[doubletList, sub_mtb_list] = get_doublet_list(mtb_list, number_of_records, flagellaName);


% ------------ tmp --------------------
%doubletList = doubletNumber;
%for doubletId = doubletList
%	sub_mtb_list{doubletId, 1} = [flagellaName '_' sprintf('%0.3d', doubletId)];
%	sub_mtb_list{doubletId, 2} = [flagellaName '_' num2str(doubletId)];
%	sub_mtb_list{doubletId, 3} = 1;
%end

configParams.ProcessingDir = '.';
configParams.StarDir = 'star';
configParams.GraphDir = 'graph';
configParams.PixelSize = '.68571';
fitParams.SortingAlong = 'Y';
% -------------------------------------

model = flagella_model(sub_mtb_list, doubletList, configParams, fitParams);

maxCutPoint = 0;
for doubletId = doubletList
	if maxCutPoint < model(doubletId).CutPoint
		maxCutPoint = model(doubletId).CutPoint;
	end
end

close all, figure

for doubletId = doubletList
	starFile = [sub_mtb_list{doubletId, 2} '.star'];
	docFile = [docDir '/' docPrefix sub_mtb_list{doubletId, 1} '.spi'];
    disp(docFile)
	
	% Reading
	%starContent = parse_star_file(starFile);
	docContent = parse_spider_doc(docFile);
 
	particleList = [1: size(docContent, 1)];

	if sub_mtb_list{doubletId, 3} == 0
		particleList = fliplr(particleList);		
	end

	% Drawing
	lengthInsert = maxCutPoint - model(doubletId).CutPoint;
	for particleId = 1:size(docContent, 1)
		%disp(pattern{docContent(particleId, 8)});		
		plot(particleList(particleId) + lengthInsert, doubletId, pattern{docContent(particleId, 8)+1}) 	
		hold on
	end
	
end

hold off
tit = regexprep(flagellaName, '_', '\\_');
title(upper(tit),'FontWeight','bold', 'FontSize', 16);
xlabel('Particles','FontWeight','bold', 'FontSize', 14)
ylabel('Doublet Number','FontWeight','bold', 'FontSize', 14)
axis([0 60 0 10])
set(gca, 'ytick', [1:9])
set(gca, 'xtick', [0:10:60])
text(2,9.5,'Proximal','FontSize', 14)
text(50,9.5,'Distal','FontSize', 14)
%set(gcf,'Position', [560 530 605 420]);
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, '-r0', [flagellaName '_' docPrefix 'plot.tif'], '-dtiff');

