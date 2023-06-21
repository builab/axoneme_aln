%-------------------------------------------------------------
% TEMPLATE
% @purpose Create 24nm picked star file from initial star file
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
listFile = 'list_chlamy.txt'; 
pixelSize = 0.68571;
period = 24;
sortDim = 2;

% ---- Program default ---------
starDir = 'star';
starFileSuffix = '_fitted.star';
fitType = 'line';
% ------------------------------

disp(['List File: ' listFile]);
disp(['Sort Dim: ' num2str(sortDim)]);
disp(['Period: ' num2str(period)]);
disp(['Pixel Size: ' num2str(pixelSize)]);

[mtb_list, number_of_records] = parse_list(listFile);

for doubletId = 1:number_of_records
    starFile = [starDir '/' mtb_list{2}{doubletId} '.star'];
    outputStarFile = [starDir '/' mtb_list{2}{doubletId} starFileSuffix];
    disp(starFile)
    disp(outputStarFile)

    origins = parse_star_file(starFile, 'origin');
    [sorted_oy, sort_indx] = sort(origins(:,sortDim), 'ascend');
    sorted_origins = origins(sort_indx, :);
   
    new_origins = auto_fit_mtb(sorted_origins, period/pixelSize, sortDim, fitType);
    write_star_file(starFile, round(new_origins), outputStarFile);
end

exit;
