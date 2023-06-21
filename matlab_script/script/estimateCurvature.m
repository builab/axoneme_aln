%-----------------------------------------------------
% Script
% @name estimateCurvature
% @date 2010/01/07
% @purpose estimate the curvature for a microtubule db
% TODO plot hist?          
%-----------------------------------------------------

workDir = '/mol/ish/Data/tandis/wt_van';
listFile = 'list_wt_van.txt';
sortDim = 2;
pixelSize = 0.68571;
period = 24;
exclusionLimit = 0.1;
distance = 5;
crit = .2;
nbins = 20;


% Program default ---------
starDir = 'star';
docDir =  'doc';
docAlnPrefix = 'doc_total_';
docClassPrefix = 'doc_class04_';
%--------------------------

disp(['List File: ' listFile])
disp(['Star Dir: ' starDir])
disp(['Doc Dir: ' docDir])
disp(['Doc Aln: ' docAlnPrefix])
disp(['Pixel Size: ' num2str(pixelSize)])

cd (workDir)

[mtb_list, number_of_records] = parse_list(listFile);

total_curvature = [];
class_list = [];
for doubletId = 1:number_of_records
	starFile = [starDir '/' mtb_list{2}{doubletId} '.star'];
	docFile = [docDir '/' docAlnPrefix mtb_list{1}{doubletId} '.spi'];
    docClass = [docDir '/' docClassPrefix mtb_list{1}{doubletId} '.spi'];
    disp(starFile)
    disp(docFile)
    disp(docClass)
    
	docContent = parse_spider_doc(docClass);
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
	p1 = origin_corr(1:end-2*distance, :);
	p2 = origin_corr(distance + 1:end-distance, :);	
	p3 = origin_corr(2*distance+1:end,:);
	
	r = 10^-3*pixelSize*radiusFrom3Pts(p1, p2, p3);
    a = anglePoints3d(p1, p2, p3)*180/pi;
	c = 1./r;
    c = [-1*ones(distance, 1); c; -1*ones(distance, 1)];
   % plot3(origin_corr(:,1), origin_corr(:,2), origin_corr(:,3), 'b*');
   % axis equal, box on
   % Eliminate outliers
    c2 = c;
    for i = distance+2:size(origin_corr, 1) - distance - 1
        if c(i) > (1+crit)*(c(i-1) + c(i+1))/2
            c2(i) = -1;
        end
    end
    total_curvature = [total_curvature; c2];
    class_list = [class_list; docContent(:,8)];
end

good_indx = total_curvature > -1;
tc2 = total_curvature(good_indx);
cl2 = class_list(good_indx);

nRed = zeros(nbins, 1);
nBlue = zeros(nbins, 1);
for i = 1:nbins
    lowLimit = (i-1)*max(tc2)/nbins;
    upLimit = i*max(tc2)/nbins;
    indx = find((tc2 > lowLimit) & (tc2 <=upLimit));
    clbin = class_list(indx);
    nRed(i) = length(find(clbin == 2));
    nBlue(i) = length(clbin) - nRed(i);
end

bar(linspace(0,max(tc2), nbins)', [nRed nBlue], 'stacked')
axis([-0.1 max(tc2) 0 700])

figure,
bar(linspace(0,max(tc2), nbins)', [nRed nBlue], 'stacked')
axis([-0.1 max(tc2) 0 20])