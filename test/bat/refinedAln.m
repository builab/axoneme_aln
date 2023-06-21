%-------------------------------------------------------------
% TEMPLATE
% @purpose Refine the rough alignment by Constrained Rapid Motif Search
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
listFile = 'list_chlamy.txt';
taFile = 'ta_chlamy.txt'; 
refFile = 'chlamy_ref_masked.spi';
maskFile = 'chlamy_3dmask.spi';
lowFreq = 0.02;
hiFreq = 0.13;
sigma = 3;
cornerX = 33;
cornerY = 21;
cornerZ = 11;
motifDimX = 29;
motifDimY = 53;
motifDimZ = 80;
phiStart = -8;
phiEnd = 8;
phiIncr = 2;
thetaStart = -3;
thetaEnd = 3;
thetaIncr = 1;
psiStart = -8;
psiEnd = 8;
psiIncr = 1;



% ---- Program default ---------
docDir = 'doc';
graphDir = 'graph';
initDocPrefix = 'doc_init_';
inplaneDocPrefix = 'doc_rough_';
refinedDocPrefix = 'doc_refined_';
binningFactor = 2;
% ------------------------------

angular_range = [phiStart phiEnd phiIncr; thetaStart thetaEnd thetaIncr; psiStart psiEnd psiIncr];

disp(['List: ' listFile])
disp(['Ref: ' refFile])
disp(['Mask: ' maskFile])
disp(['Tilt Angle File: ' taFile])

[mtb_list, number_of_records] = parse_list(listFile);
taContent = parse_ta_list(taFile);
ref = tom_spiderread2(refFile);
ref = tom_bin(ref.data, binningFactor-1);
motif = ref(cornerY:cornerY+motifDimY-1, ... 
            cornerX:cornerX+motifDimX-1, ...
            cornerZ:cornerZ+motifDimZ-1);
motif = -motif;
motif = motif - mean(mean(mean(motif)));

mask = tom_spiderread2(maskFile);
mask = tom_bin(mask.data, binningFactor-1);
mask = mask(cornerY:cornerY+motifDimY-1, ...                   
            cornerX:cornerX+motifDimX-1, ...
            cornerZ:cornerZ+motifDimZ-1);
 

for doubletId = 1:number_of_records
    docInitContent = parse_spider_doc(strcat(docDir,'/', initDocPrefix, mtb_list{1}{doubletId}, '.spi'));
    euler01 = docInitContent(floor((1+size(docInitContent,1))/2), 1:3);
    docInplaneContent = parse_spider_doc(strcat(docDir,'/', inplaneDocPrefix, mtb_list{1}{doubletId}, '.spi'));
    euler02 = docInplaneContent(1,1:3);
    mat01 = matrix3_from_euler(euler01);
    mat02 = matrix3_from_euler(euler02);
    mat = mat02*mat01;
    euler = euler_from_matrix3(mat);
    
    initFile = regexprep(mtb_list{1}{doubletId},  '(_\d+)$', '_rough$1');
    origFile = [initFile '.spi'];
    
    outputDoc = [docDir '/' refinedDocPrefix mtb_list{1}{doubletId} '.spi'];
    
    for j = 1:size(taContent,1)
        if ~isempty(strfind(mtb_list{2}{doubletId}, taContent{j,1}))
            tilt_info  = taContent{j,2};
            break;
        end
    end

    targetFile = [initFile '.spi'];
    disp(['Refining ' targetFile])
    target = tom_spiderread2(targetFile);
    target = tom_bin(target.data, binningFactor-1);
    % Invert contrast
    target = -target;
    target = target - min(min(min(target)));
    peak_list = cramos_mask(motif, target, angular_range, mask, [lowFreq hiFreq sigma], tilt_info, euler); 
    [peak_sort, peak_indx] = sort(peak_list(:,7),'descend');
    max_peak = peak_list(peak_indx(1),:);
    
    disp(origFile)
    disp(max_peak)

    [fitted_target, rev_tfm] = reverse_cramos(motif, target, angular_range, [cornerX cornerY cornerZ], max_peak);

    rev_tfm(4:6) = rev_tfm(4:6)*binningFactor; % Because of binning, tranlation is double
    write_spider_doc([rev_tfm max_peak(7)], outputDoc);
end

exit;
