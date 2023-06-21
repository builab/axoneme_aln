%---------------------------------------------------------------------
% Script
% @purpose Fit mtb from a list with consideration of CCC & auto smoothening
% @date 20080410
% @TODO improve auto_mtb_fit function to use with this
%---------------------------------------------------------------------

listFile =  '/mol/ish/Data/Huy_tmp/oda1hm_auto/list_oda1hm.txt.bak';
starDir = '/mol/ish/Data/Huy_tmp/oda1hm_auto/star';
docDir =  '/mol/ish/Data/Huy_tmp/oda1hm_auto/doc';
docAlnPrefix =  'doc_total_';
pixelSize =  0.4988;
period =  24; % nm
sortDim =  2; % 2 = Y
tolAngle =  10; % Angle to smoothout
tolDistance =  4;
exclusionLimit =  .08;
fittedStarSuffix = '.star';


disp(['List File: ' listFile])
disp(['Star Dir: ' starDir])
disp(['Doc Dir: ' docDir])
disp(['Doc Aln: ' docAlnPrefix])
disp(['Pixel Size: ' num2str(pixelSize)])

[mtb_list, number_of_records] = parse_list(listFile);

flagName = regexprep(mtb_list{2}{1}, '_\d$', '');


for i = 1:number_of_records
    if (i==number_of_records) || (isempty(strfind(mtb_list{2}{i}, flagName)))
	    %outputGraph = [graphDir '/' flagName '_fitted.tiff'];
        set(gcf, 'Unit', 'pixels', 'Position', [0 0 500 800]);
        set(gcf, 'PaperPositionMode', 'auto')
        %print(gcf, '-r0', outputGraph, '-dtiff');
        close(gcf);
		pause % To stop at the end of each flagella
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
    end


	starFile = [starDir '/' mtb_list{2}{i} '.star'];
    docFile = [docDir '/' docAlnPrefix mtb_list{1}{i} '.spi'];
	outputStarFile = [starDir '/fitted/' mtb_list{2}{i} fittedStarSuffix];
	disp(['Flagella: ' flagName])
    disp(['Input Doc: ' docFile])
    disp(['Original Star File: ' starFile])
	disp(['Output Star File: ' outputStarFile])
	disp(outputStarFile)

	origin = parse_star_file(starFile, 'origin');
	transform = parse_spider_doc(docFile);

    good_origin_indx = transform(:,7) > exclusionLimit;
    origin = origin(good_origin_indx, :); 
    transform = transform(good_origin_indx, :);
    tfm_origins = transform_pts(origin, transform);

    smoothen_origins = smoothen_line(tfm_origins, tolDistance);
    [oxyzi, len] = fit_mtb_line2(smoothen_origins, sortDim, tolAngle);
	[coor, indx] = pick_good_pts(smoothen_origins, period/pixelSize, tolDistance);
	
	coor_vec = repmat(coor,size(oxyzi,1),1);
    distance = sqrt(sum((coor_vec-oxyzi).^2, 2));
    [val, min_indx] = min(distance);
	new_origins = bf_pick(len, min_indx, period/pixelSize);
	disp(size(new_origins))

	% Output
	write_star_file(starFile, round(oxyzi(new_origins,:)), outputStarFile);
	
	plot3(oxyzi(:,1), oxyzi(:,2), oxyzi(:,3), 'b-')
	hold on
	plot3(smoothen_origins(:,1), smoothen_origins(:,2), smoothen_origins(:,3), 'r.')
    title(strrep(flagName, '_', '\_'), 'FontWeight', 'bold');
    doubletNumber = regexp(mtb_list{2}{i}, '\d$', 'match');
    h = text(oxyzi(1,1) + 10, oxyzi(1,2) + 10, oxyzi(1,3), doubletNumber{1});
    set(h, 'FontWeight', 'bold');
    axis equal
    axis([0 2048 0 2048 0 400])
    view(10, 50)
    hold on
    box on
end
