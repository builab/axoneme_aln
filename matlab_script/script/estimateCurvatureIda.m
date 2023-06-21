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
	
	%pts = origin_corr(30:32,:);
	%plane = createPlane(pts);
	%n = planeNormal(plane);
	%rotang(1) = atan2(n(2), v(1));
	%rotang(2) = acos(n(3));
	%m1 = rotationOz(rotang(1));
	%m2 = rotationOy(rotang(2));
	%xfm = composeTransforms3d(m1, m2);
	%p1 = transformPoint3d(pts(1,:), xfm);
	%p2 = transformPoint3d(pts(2,:), xfm);
	p1 = origin_corr(1:end-2, :);
	p2 = origin_corr(2:end-1, :);	
	p3 = origin_corr(3:end,:);
	
	r = 10^-3*pixelSize*radiusFrom3Pts(p1, p2, p3);
    a = anglePoints3d(p1, p2, p3)*180/pi;
	r = [r(1); r ; r(end)];
	c = 1./r;
    plot3(origin_corr(:,1), origin_corr(:,2), origin_corr(:,3), 'b*');
    axis equal, box on
end
