%-------------------------------------------------------------
% TEMPLATE
% @purpose Generate initial document with estimated Euler angles
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
listFile = 'list_chlamy.txt'; 
pixelSize = 0.68571;
sortDim = 2;
doGuessPsi= 1;

% ---- Program default ---------
starDir = 'star';
docDir = 'doc';
graphDir = 'graph';
initDocPrefix = 'doc_init_';
smoothingLimit = 13;
% ------------------------------

disp(['List File: ' listFile])
disp(['Sort Dim: ' num2str(sortDim)])
disp(['Pixel Size: ' num2str(pixelSize)])


[mtb_list, number_of_records] = parse_list(listFile);

for i = 1:number_of_records
    if i == 1
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
        [doublet_list, sub_mtb_list] = get_doublet_list(mtb_list, number_of_records, flagName);
       
        flagellaModel = flagella_model_new(sub_mtb_list, doublet_list, starDir, sortDim, smoothingLimit, pixelSize, graphDir);
    end
    if isempty(strfind(mtb_list{2}{i}, flagName))
        % Extract flagella info
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
        [doublet_list, sub_mtb_list] = get_doublet_list(mtb_list, number_of_records, flagName);
        flagellaModel = flagella_model_new(sub_mtb_list, doublet_list, starDir, sortDim, smoothingLimit, pixelSize, graphDir);
    end
    
    doublet_id = regexp(mtb_list{2}{i}, '\d$', 'match');
    doublet_id = str2double(doublet_id);

    starFile = [starDir '/' mtb_list{2}{i} '.star'];
    docInitFile = [initDocPrefix mtb_list{1}{i} '.spi'];
    disp(starFile)
        
    origins = parse_star_file(starFile, 'origin');

    % Guessing Phi & Theta
    rotang = mtb_init_rotang(origins, mtb_list{3}(i));
    transform = zeros(size(origins, 1), 6);
    transform(:, 1:3) = rotang;
    
    % Get estimated psi from flagella model
    if (doGuessPsi)
        psimat = flagellaModel(doublet_id).RotAng(3)*ones(size(origins, 1),1); 
        transform(:,3) = psimat;
    end

    write_spider_doc(transform, [docDir '/' docInitFile]);
end

exit;
