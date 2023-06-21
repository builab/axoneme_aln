%-------------------------------------------------------------
% TEMPLATE
% @purpose Roughly align subaverage and reference using inplane search
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
listFile = 'list_chlamy.txt'; 
refFile = 'chlamy_ref_masked.spi';
noSliceToAvg = 20;
lowFreq = 0.01;
hiFreq = 0.08;
sigma = 3;
objectSize = 90;
maxXYTranslation = 14;
maxZTranslation =  20;
iteration = 10;
doZTranslation = 1;
angleLowerLimit = -60;
angleUpperLimit = 60;
critLimit = 0.3;

% ---- Program default ---------
docDir = 'doc';
graphDir = 'graph';
% ------------------------------

disp(['List: ' listFile])
disp(['Ref: ' refFile])
disp('');

[mtb_list, number_of_records] = parse_list(listFile);
ref = tom_spiderread2(refFile);
ref = ref.data;
ref = ifftn(fftn(ref).*ifftshift(bp_filter(size(ref), lowFreq, hiFreq, sigma)), 'symmetric');
ref2d = sum(ref(:,:, floor(size(ref,3)/2) - floor(noSliceToAvg/2) + 1: floor(size(ref,3)/2)+floor(noSliceToAvg/2)), 3);
ref2d = vol2double(ref2d);
origin = floor(size(ref)/2) + 1;
box_init =  [origin(1)/2 origin(1)*3/2 ...
            origin(2)/2 origin(2)*3/2];
box = [origin(1)-maxXYTranslation origin(1)+maxXYTranslation ...
    origin(2)-maxXYTranslation origin(2)+maxXYTranslation ...
    origin(3)-maxZTranslation origin(3)+maxZTranslation];

potentialFailure = [];

for doubletId = 1:number_of_records
    imFile = [mtb_list{1}{doubletId} '.spi'];
    vol = tom_spiderread2(imFile);
    vol = vol.data;
    vol = ifftn(fftn(vol).*ifftshift(bp_filter(size(vol), lowFreq, hiFreq, sigma)), 'symmetric');

    
    im = sum(vol(:,:, floor(size(vol,3)/2) - floor(noSliceToAvg/2) + 1: floor(size(vol,3)/2)+floor(noSliceToAvg/2)), 3);
    % Masking circular mask
    
    circular_mask = tom_sphere(size(im), floor(min(size(im))/2) - 15, 3);
    bg_val = sum(sum(im.*circular_mask))/sum(sum(circular_mask));
    im = im.*circular_mask + bg_val*(1-circular_mask);

    % Inplane alignment
    cc = tom_korr(im, ref2d, 'xcf');
    [c, val] = tom_peak(cc, round(box_init));
    c = [c(1)-origin(1), c(2)-origin(2)];
    im_shift = tom_shift(vol2double(im), c);
    [trans,rot, delta, moved_part]=tom_align2d_new(im_shift,ref,objectSize, maxXYTranslation, iteration, [angleLowerLimit angleUpperLimit]);
    im_aln = tom_rotate(vol2double(im), -rot);
    rot_rad = rot*pi/180;
    trans = trans  + ([cos(rot_rad) sin(rot_rad); -sin(rot_rad) cos(rot_rad)]*c')';
    im_aln = tom_shift(im_aln, trans);
    im_aln = vol2double(im_aln);
    im_out = zeros(size(im,1), size(im,2)*2);
    im_out(:,1:size(im,1)) = vol2double(im);
    im_out(:,size(im,1)+1:end)=im_aln;
    imwrite(flipud(im_out), [graphDir '/RoughAln_' mtb_list{1}{doubletId} '.png']);

    transform = zeros(1,7);
    transform(1) = -rot;
 
    if (doZTranslation) 
        % Z alignment   
        vol_rot = tom_rotate(vol, [-rot 0 0]);
        vol_aln = tom_shift(vol_rot, [trans(1) trans(2) 0]);
        cc3 = tom_corr(vol_aln, ref, 'xcf');
        [c3d, val3d] = tom_peak(cc3, box);
        c3d = c3d - origin;
        
        transform(4:6) = [trans(2)+c3d(2) trans(1)+c3d(1) c3d(3)];
        transform(7) = val3d;

    else
        transform(4:5) = [trans(2) trans(1)];
        transform(7) = val;
    end
    
	if (transform(7) < critLimit)
		potentialFailure = [potentialFailure; doubletId];
	end
    % Write output  
    write_spider_doc(transform, [docDir '/doc_rough_' mtb_list{1}{doubletId} '.spi']);
    disp([mtb_list{1}{doubletId} ' -> ' sprintf('%7.2f %7.2f %7.2f %7.2f %7.2f %7.2f    %5.4f', transform)])    
end

if isempty(potentialFailure)
	exit;
end

disp('');
disp('Potential Failure Doublet');
for i = 1:size(potentialFailure, 1)
	disp(['   ' mtb_list{1}{potentialFailure(i)}]);
end

exit;
