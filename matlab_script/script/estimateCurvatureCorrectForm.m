%-----------------------------------------------------
% Script
% @name estimateCurvature
% @date 2010/01/07
% @purpose estimate the curvature for a microtubule db
%           
%-----------------------------------------------------

listFile = 'list_test.txt';
sortDim = 2;
pixelSize = 0.68571;
period = 24;
exclusionLimit = 0.1;
distance = 4;
degree = 2;

% Program default ---------
starDir = 'star';
docDir =  'doc';
docAlnPrefix = 'doc_total_';
%--------------------------

disp(['List File: ' listFile])
disp(['Star Dir: ' starDir])
disp(['Doc Dir: ' docDir])
disp(['Doc Aln: ' docAlnPrefix])
disp(['Pixel Size: ' num2str(pixelSize)])

[mtb_list, number_of_records] = parse_list(listFile);


for doubletId = 1:number_of_records
	starFile = [starDir '/' mtb_list{2}{doubletId} '.star'];
	docFile = [docDir '/' docAlnPrefix mtb_list{1}{doubletId} '.spi'];
    disp(starFile)
    disp(docFile)
	
	origin = parse_star_file(starFile, 'origin');
	transform = parse_spider_doc(docFile);
	
	origin_corr = transform_pts(origin, transform);

    particleId = size(origin_corr, 1);
    c = -1*ones(particleId, 1);
    for i = distance + 1:particleId-distance
    	plane = createPlane(origin_corr(i-distance:distance:i+distance,:));
        n = planeNormal(plane);
    	rotang(1) = atan2(n(2), n(1));
        rotang(2) = acos(n(3));
    	m1 = rotationOz(rotang(1));
        m2 = rotationOy(rotang(2));
    	xfm = composeTransforms3d(m1, m2);
        pts_xf = transformPoint3d(origin_corr(i-distance:distance:i+distance,:), xfm);
        c_tmp = curvature(10^-3*pixelSize*pts_xf(:,1:2), 'polynom', degree);

        c(i) = c_tmp(2);
        
    end
	
    
    
    %plot3(origin_corr(:,1), origin_corr(:,2), origin_corr(:,3), 'b*');
    %axis equal, box on
end
