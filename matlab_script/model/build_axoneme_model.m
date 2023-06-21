% -------------------------------------------------
% Script: build_axoneme_model.m
% Purpose: Build axoneme model from alignment file
% Require geom3d 
% HB 20080722
% -------------------------------------------------

% TODO
% Build outer arm

outputModelFile = '/mol/ish/Data/Huy_tmp/axoneme/wt14a.mod';
outputRsModelFile = '/mol/ish/Data/Huy_tmp/axoneme/wt14a_rs.mod';
listFile = '/mol/ish/Data/20080429wt/wt14/AVG/list_wt14a.txt';
docInputPrefix = 'doc_total_';
processingDir = '/mol/ish/Data/20080429wt/wt14/AVG';
docDir = '/mol/ish/Data/20080429wt/wt14/AVG/doc';
starDir = '/mol/ish/Data/20080429wt/wt14/AVG/star';
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

		% Building doublet & outer dynein arms
		for pointId = 1:size(xformOrigin,1)
			%circle = createCircle3d(xformOrigin(pointId,:), radius, transform(pointId,2)*pi/180, transform(pointId,1)*pi/180);			

			xformMat = rotationOz(transform(pointId,3)*pi/180)*rotationOy(transform(pointId,2)*pi/180)*rotationOz(transform(pointId,1)*pi/180);			
			xformPts = transformPoint3d(xformOrigin(pointId,:), xformMat);
			xformPtsMtbA = xformPts + mtbAshift;
			xformPtsMtbB = xformPts + mtbBshift;
			ptsMtbA = transformPoint3d(xformPtsMtbA, inv(xformMat));
			ptsMtbB = transformPoint3d(xformPtsMtbB, inv(xformMat));

			% ODA
			xformPtsOdaA = xformPts + odaAshift;
			xformPtsOdaB = xformPts + odaBshift;
			xformPtsOdaG = xformPts + odaGshift;

			ptsOdaA = transformPoint3d(xformPtsOdaA, inv(xformMat));
			ptsOdaB = transformPoint3d(xformPtsOdaB, inv(xformMat));
			ptsOdaG = transformPoint3d(xformPtsOdaG, inv(xformMat));

			% Combine angle to produce the orientation of 3 rings
			matOda1 = matrix3_from_euler(odaArot);
			matOda2 = matrix3_from_euler(transform(pointId,1:3));
			circle = createCircle3d([ptsOdaA dynRadius], euler_from_matrix3(matOda2*matOda1)*pi/180);						
			odaA.(['odaA_' num2str(pointId)]) = circle;

			if pointId == 1
				doublet.(['mtbA_' num2str(doubletId)]) = ptsMtbA;
				doublet.(['mtbB_' num2str(doubletId)]) = ptsMtbB;
			else
				doublet.(['mtbA_' num2str(doubletId)]) = [doublet.(['mtbA_' num2str(doubletId)]); ptsMtbA];
				doublet.(['mtbB_' num2str(doubletId)]) = [doublet.(['mtbB_' num2str(doubletId)]); ptsMtbB];				
			end
			
			% drawing
			drawCircle3d(xformOrigin(pointId,:), radius, transform(pointId,2)*pi/180, transform(pointId,1)*pi/180);
			hold on			
		end
		
		directives.name = 'Doublet';
		directives.type = 'open';
		doublet.directives = directives;		
		model.doublet = doublet;

		odaA.directives.name = ['odaA d' num2str(doubletId)];
		odaA.directives.type = 'open';
		model.(['odaA_d' num2str(doubletId)]) = odaA;

		axis equal, box on

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
					rsObject.contour1 = pointRs1end;
				else
					rsObject.contour1 = [rsObject.contour1; pointRs1end];
				end
			end		
			% End RS model 

			contourId = contourId + 1;
			drawEdge([pointRs1start pointRs1end]);
			hold on
			drawEdge([pointRs2start pointRs2end]);
			hold on
		end
		
		% Insert directives
		rs1Object.directives.name = ['RS 1 d' num2str(doubletId) ];
		rs2Object.directives.name = [' RS 2 d' num2str(doubletId) ];
		rs1Object.directives.type = 'open';
		rs2Object.directives.type = 'open';

		rsObject.directives.name = ['RS1 d' num2str(doubletId) ];
		rsObject.directives.pointsize = 20;
		rsObject.directives.type = 'scattered';
		
		model.(['rs1_d' num2str(doubletId)]) = rs1Object;
		model.(['rs2_d' num2str(doubletId)]) = rs2Object;
		rsModel.(['rs1_d' num2str(doubletId)]) = rsObject;
end

write_imod_ascii(model, outputModelFile);


write_imod_ascii(rsModel, outputRsModelFile);
