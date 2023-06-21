%%--------------------------------------------------------
% Script: plotRsOrganizationList.m
% Purspose: plot Radial spoke Organization around the central pair for a list of flagella
% Date: 2010/11/08
% TODO only allow round shape flagella to be analyzed
%%--------------------------------------------------------

listFile = 'list_flagella_prox.txt';
% default parameter
docPrefix = 'doc_total_';
pixelSize = .68571; %nm
period = 96; %nm


upperY = 1200; % Only use particle in this region, better to choose the region with round shape
lowerY = 800; % 

% ---- Program default ---------
threshold = .2;
docDir = 'doc';
starDir = 'star';
graphDir = 'graph';
% ------------------------------

disp(['List: ' listFile])

[mtb_list, number_of_records] = parse_list(listFile);
flagellaList = parse_flagella_name_from_list(mtb_list);

% output file
outputFile = [regexprep(listFile,'list_(.*).txt', '$1')  '_rs_organization.tif'];

close all
figure

totalZcumm = [];
totalZdiff = [];
for i = 1:numel(flagellaList)
	dataset = flagellaList{i};
	zarray = [];

	for doubletId = 1:9
		docInputFile = [docDir '/' docPrefix dataset '_' sprintf('%0.3d', doubletId) '.spi'];
		starFile = [starDir '/' dataset '_' num2str(doubletId) '.star'];
		disp(['Reading ' docInputFile]);
		disp(['Reading ' starFile]);
	
	docInputContent = parse_spider_doc(docInputFile);
	origin = parse_star_file(starFile, 'origin');

	% Find point id
	[minValue, pointId] = min(abs(origin(:,2) - (upperY+lowerY)/2));

	point = origin(pointId,:);
	xform = docInputContent(pointId,:);

	shift = xform(4:6);
	rot = xform(1:3);

	mat3 = matrix3_from_euler(rot);
	
	origin_xform = (mat3*point' + shift')';
    zarray = [zarray; origin_xform(3)];
    
    %plot(origin_xform(1), origin_xform(2), '*b');
    %hold on
end

zdiff = [0; diff(zarray)]*pixelSize;
zdiff = mod(zdiff, ones(9, 1)*period); % Convert to all positive
totalZdiff = [totalZdiff; zdiff'];
zcumm = cumsum(zdiff); % Convert to cummulative sum to draw
totalZcumm = [totalZcumm; zcumm'];

plot([1:9]', zcumm, '+b')
axis([0 9.5 0 600])
hold on

end


title(['Radial spoke organization around the central pair (' num2str(numel(flagellaList)) ' flagella)'])
xlabel('Doublet number')
ylabel('Distance along the central pair')
hold off
print(gcf, '-r0', [graphDir '/' outputFile], '-dtiff');

% Graph with standard error
meanZ = mean(totalZcumm, 1);
stdErrorZ = std(totalZcumm, 1)/sqrt(size(totalZcumm, 1));
errorbar([1:9], meanZ, stdErrorZ)
axis([0 9.5 0 600])

print(gcf, '-r0', [graphDir '/errorBar_' outputFile], '-dtiff');
