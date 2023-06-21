% -------------------------------------------------
% Script: build_axoneme_model.m
% Purpose: Build axoneme model from alignment file
% Require geom3d 
% HB 20080722
% -------------------------------------------------

% TODO
% Display average distance between consecutive RS

% ---- Important -------
startingDoublet = 2;
tmp = 1:9;

if startingDoublet ~= 1
	doubletOrder = zeros(1,9);
	doubletOrder(startingDoublet:9) = tmp(startingDoublet:9) - tmp(startingDoublet-1);
	doubletOrder(1:startingDoublet-1) = [1:startingDoublet-1] + doubletOrder(9);
end

% ----------------------
outputRsModelFile = 'wt14a_rs.mod';
listFile = 'list_wt14a.txt';
docInputPrefix = 'doc_total_';
docDir = 'doc';
starDir = 'star';
radius = 12;
sortDim = 2;
rs1Shift = [15 0 -36];
rs2Shift = [15 0 9];
rsLength = 40;
pixelSize = .68571; % nm
mtbAshift = [-6 -4 0];
mtbBshift = [-14 16 0];
odaAshift = [-16 -55 -1];
odaBshift = [-12 -43 4];
odaGshift = [-2 -33 9];
odaArot = [85 287 0]; % [Theta phi] in degree
odaBrot = [90 97 0];
odaGrot = [80 99 0]; 
dynRadius = 6;

rot = [106 90 0];
drawingStyle = {'ro-', 'go-', 'bo-', 'co-', 'mo-', 'yo-', 'ko-', 'r*', 'b*'};

% For RS model only
upperY = 1200;
lowerY = 500;

[mtb_list, number_of_records] = parse_list(listFile);



% Building doublet
for doubletId = 1:number_of_records
		for varId = 1:4				
				varStr = ['ida_v' num2str(varId)];
		        docInputFile = [docDir '/' docInputPrefix regexprep(mtb_list{1}{doubletId}, '(\d\d\d)$', [varStr '_$1']) '.spi'];
				starFile = [starDir '/' mtb_list{2}{doubletId} sprintf('ida_v%d', varId) '.star'];
				disp(['Reading: ' docInputFile]);
				disp(['Reading: ' starFile]);
				docInputContent = parse_spider_doc(docInputFile);
				starInputContent = parse_star_file(starFile, 'origin');
				if (varId == 1) 
					transform = docInputContent;
					origin = starInputContent;
					transform01 = docInputContent; % For RS drawing
					origin01 = starInputContent; % For Rs drawing
				else
					transform = [transform; docInputContent];
					origin = [origin; starInputContent];
				end
		end

		[sort_origin_y, sort_indx] = sort(origin(:,sortDim), 'ascend');
		origin = origin(sort_indx, :);
		transform = transform(sort_indx, :);

		xformOrigin = transform_pts(origin, transform);
		%[oxyzi, len] = fit_mtb_line2(xformOrigin, 2, 10);

		if mtb_list{3}(doubletId) == 1
			xformOrigin = flipud(xformOrigin);
			transform = flipud(transform);
		end

	
		% draw the radial spoke
		xformOrigin01 = transform_pts(origin01, transform01);
		% check flagella direction & flip if necessary CHECK CHECK CHECK
		if mtb_list{3}(doubletId) == 1
			xformOrigin01 = flipud(xformOrigin01);
			transform01 = flipud(transform01);
		end

		% Initialize model
		rsObject = [];
		contourId = 1;
		for pointId = 1:size(xformOrigin01)-1
			%v = xformOrigin01(pointId+1,:) - xformOrigin01(pointId,:);
			%scale01 = distanceRs1/sqrt(sum(v.^2));
			%scale02 = distanceRs2/sqrt(sum(v.^2));


			% Rs1
			%pointRs1 = xformOrigin01(pointId,:) + scale01*v;
			%pointRs2 = xformOrigin01(pointId,:) + scale02*v;

			% draw line (on a plane normal to line connecting two consecutive points & has a specific angle compare to psi)	
			xformMat = rotationOz(transform01(pointId,3)*pi/180)*rotationOy(transform01(pointId,2)*pi/180)*rotationOz(transform01(pointId,1)*pi/180);			
			xformPts = transformPoint3d(xformOrigin01(pointId,:), xformMat);
			xformRs01start = xformPts + rs1Shift;
			xformRs02start = xformPts + rs2Shift;
			xformRs01end = xformPts + rs1Shift + [rsLength 0 0];
			xformRs02end = xformPts + rs2Shift + [rsLength 0 0];		
			pointRs1start = transformPoint3d(xformRs01start, inv(xformMat));
			pointRs2start = transformPoint3d(xformRs02start, inv(xformMat));
			pointRs1end = transformPoint3d(xformRs01end, inv(xformMat));
			pointRs2end = transformPoint3d(xformRs02end, inv(xformMat));


			rs1Object.(['contour' num2str(contourId)]) = [pointRs1start; pointRs1end];
			rs2Object.(['contour' num2str(contourId)]) = [pointRs2start; pointRs2end];

			% RS model only for evaluation of helical form (draw between lower & upperY)
			if pointRs1end(2) >= lowerY && pointRs1end(2) <= upperY
				if ~isfield(rsObject, 'contour1')				
					rsObject.contour1 = pointRs1start;
				else
					rsObject.contour1 = [rsObject.contour1; pointRs1start];
				end
			end		
			% End RS model 
			% Draw Y value
			xformMat2 = rotationOy(rot(2)*pi/180)*rotationOz(rot(1)*pi/180);	
			xformPts = transformPoint3d(pointRs1start, xformMat2);
			plot(doubletOrder(doubletId)*10, xformPts(3), drawingStyle{doubletOrder(doubletId)})	
			title(listFile);
			hold on
			axis([0 100 100 1400]);

			contourId = contourId + 1;			

		end
		
		% Insert directives
		rs1Object.directives.name = ['RS 1 d' num2str(doubletOrder(doubletId)) ];
		rs2Object.directives.name = [' RS 2 d' num2str(doubletOrder(doubletId)) ];
		rs1Object.directives.type = 'open';
		rs2Object.directives.type = 'open';

		rsObject.directives.name = ['RS1 d' num2str(doubletOrder(doubletId)) ];
		rsObject.directives.pointsize = 20;
		rsObject.directives.type = 'scattered';
		
		model.(['rs1_d' num2str(doubletOrder(doubletId))]) = rs1Object;
		model.(['rs2_d' num2str(doubletOrder(doubletId))]) = rs2Object;
		rsModel.(['rs1_d' num2str(doubletOrder(doubletId))]) = rsObject;
end

write_imod_ascii(rsModel, outputRsModelFile);
