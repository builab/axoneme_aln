%-------------------------------------------------------------
% TEMPLATE
% @purpose Fit Ida from original star file & aligned documents
% @version 1.0
% @date 20080301
% @new: exclusionLimit to eliminate particles with low CCC to
%		be included	
%-------------------------------------------------------------
listFile = 'list_chlamy.txt';
sortDim = 2;
pixelSize = 0.67;

% Program default ---------
starDir = 'star';
docDir =  'doc';
graphDir = 'graph';
docAlnPrefix = 'doc_total_';
initIdaDocPrefix = 'doc_init_'; 
tolAngle = 10;
tolDistance = 4;
%--------------------------

disp(['List File: ' listFile])
disp(['Star Dir: ' starDir])
disp(['Doc Dir: ' docDir])
disp(['Doc Aln: ' docAlnPrefix])
disp(['Pixel Size: ' num2str(pixelSize)])
disp(['Exclusion Limit: ' num2str(exclusionLimit)])

[mtb_list, number_of_records] = parse_list(listFile);

flagName = regexprep(mtb_list{2}{1}, '_\d$', '');

for i = 1:number_of_records
	if (i==number_of_records) || (isempty(strfind(mtb_list{2}{i}, flagName)))	
		outputGraph = [graphDir '/' flagName '_ida_fitted.tiff'];
		set(gcf, 'Unit', 'pixels', 'Position', [0 0 500 800]);		
		set(gcf, 'PaperPositionMode', 'auto')	
		print(gcf, '-r0', outputGraph, '-dtiff');		
		close(gcf);
		flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
	end

	starFile = [starDir '/' mtb_list{2}{i} '.star'];
	docFile = [docDir '/' docAlnPrefix mtb_list{1}{i} '.spi'];
	disp(['Flagella: ' flagName])
	disp(docFile)
	disp(starFile)
	origin = parse_star_file(starFile, 'origin');
	transform = parse_spider_doc(docFile);
  	
	% Exclude low value particle
	good_origin_indx = transform(:,7) > exclusionLimit;
	origin = origin(good_origin_indx, :); 
	transform = transform(good_origin_indx, :);

	origin_new = transform_pts(origin, transform);
	smoothen_origins = smoothen_line(origin_new, tolDistance);
	[oxyzi, len] = fit_mtb_line2(smoothen_origins, sortDim, tolAngle);

	plot3(oxyzi(:,1), oxyzi(:,2), oxyzi(:,3), 'b-')	
	title(strrep(flagName, '_', '\_'), 'FontWeight', 'bold');
	doubletNumber = regexp(mtb_list{2}{i}, '\d$', 'match');
	h = text(oxyzi(1,1) + 10, oxyzi(1,2) + 10, oxyzi(1,3), doubletNumber{1});
	set(h, 'FontWeight', 'bold');
	axis equal
	axis([0 2048 0 2048 0 400])
	view(10, 50)
	hold on
	box on

	% Picking good points on the line
	[coor, indx] = pick_good_pts(smoothen_origins, period/(4*pixelSize), tolDistance);

	% Find index of point on fitted line nearest to good points
	coor_vec = repmat(coor,size(oxyzi,1),1);
	distance = sqrt(sum((coor_vec-oxyzi).^2, 2));
	[val, min_indx] = min(distance); 

	% Pick IDA
	doInvert = mtb_list{3}(i);
	pick_ind = ida_bf_pick(len, min_indx, period/pixelSize, 4);

	% Invert variants
	if (doInvert)
		disp('Inverted');
		tmp_ind = pick_ind{2};
		pick_ind{2} = pick_ind{4};
		pick_ind{4} = tmp_ind;
	end

	for var_ind = 1:4
		starFile = [starDir '/' mtb_list{2}{i} '.star'];
		selected_ind = pick_ind{var_ind};
		selected_ind = sort(selected_ind, 'ascend');
		data = oxyzi(selected_ind, :);
		outputStarFile = [starDir '/' mtb_list{2}{i} 'ida_v' num2str(var_ind) '.star'];
		disp(outputStarFile)
		write_star_file(starFile, round(data), outputStarFile)
    end

	plot3(data(:,1), data(:,2), data(:,3), 'ro');
	hold on   

	% Merge 4 ida index into 1 oda_indx
	oda_ind = [];
	for var_ind = 1:4
	oda_ind = [oda_ind ; pick_ind{var_ind} var_ind*ones(size(pick_ind{var_ind}))];
	end

	oda_origins =  oxyzi(oda_ind(:,1) , :);
	[sorted_dim, sorted_indx] = sort(oda_origins(:, sortDim), 'ascend');
	sorted_oda_origins = oda_origins(sorted_indx, :);

	rotang = mtb_init_rotang(sorted_oda_origins, mtb_list{3}(i));
	idaVarInd = oda_ind(sorted_indx,2);

	for var_ind = 1:4		
		rotang_ida = rotang(find(idaVarInd == var_ind), :);
		transform_ida = zeros(size(rotang_ida, 1), 6);
		transform_ida(:,1:3) = rotang_ida;
		number_of_particles = size(transform, 1);
		% Scale angle data into -180 -> 180 degree
		transform_ida(:,3) = mean(angle_norm(transform(floor(number_of_particles/2)-3:floor(number_of_particles/2)+3, 3)))*ones(size(transform_ida(:,3)));
		docInitOut =  [docDir '/' initIdaDocPrefix regexprep(mtb_list{1}{i}, '(_\d+)$',['_ida_v' num2str(var_ind) '$1.spi'])];
		disp(docInitOut)
		write_spider_doc(transform_ida, docInitOut);
	end
end


exit;
