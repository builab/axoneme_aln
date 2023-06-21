%-------------------------------------------------------------
% TEMPLATE
% @purpose Calculate weight factor
% @version 1.0
% @date 20080301
% @new a new lower limit which prevents particles having CCC less than
%       a lower limit to be averaged.
%-------------------------------------------------------------
volSize = [2 2 2]*100;
listFile =  'list_chlamy.txt';
taFile = 'ta_chlamy.txt';
weightFile = 'weight_chlamy.spi';
lowerLimit = .17;

% --- Program default -----
docInputPrefix = 'doc_total_';
docDir = 'doc';
%--------------------------

disp(['Vol Size: ' num2str(volSize)])
disp(['List File: ' listFile])
disp(['Tilt Angle: ' taFile])
disp(['Weight File: ' weightFile])
disp(['Lower Limit: ' num2str(lowerLimit)]);

[mtb_list, number_of_records] = parse_list(listFile);

taContent = parse_ta_list(taFile);

alnContent = [];
taListContent = [];

for doubletId = 1:number_of_records
    docInputFile = [docDir '/' docInputPrefix mtb_list{1}{doubletId} '.spi'];
    disp(['Reading ' docInputFile];
    docInputContent = parse_spider_doc(docInputFile);

    alnContent = [alnContent ; docInputContent(:,[1:3 7]);
    
    for j = 1:size(taContent,1)
        if ~isempty(strfind(mtb_list{2}{doubletId}, taContent{j,1}))
            tilt_info  = taContent{j,2};
            break;
        end
    end
    
    taListContent = [taListContent; repmat(tilt_info, size(docInputContent,1), 1)];

end

weight = calc_weight_factor_new(volSize, alnContent, taListContent, lowerLimit);
tom_spiderwrite2(weightFile, weight);

exit;
