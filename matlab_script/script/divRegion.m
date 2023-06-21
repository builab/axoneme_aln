%-------------------------------------------------------------
% TEMPLATE
% @purpose divide the flagella into region based on doublet 1
% @version 1.0
% @date 20101004
%-------------------------------------------------------------
%%% --- START HEADER ---
listFile = 'list_ida10_6x_region.txt';
sortDim = 2;
docAlnPrefix = 'doc_total_';
docRegPrefix = 'doc_region_';
%%% --- END HEADER -----

% ---- Program default ---------
starDir = 'star';
docDir = 'doc';
% ------------------------------

disp(['List File: ' listFile])
disp(['Sort Dim: ' num2str(sortDim)])


[mtb_list, number_of_records] = parse_list(listFile);


for i = 1:number_of_records
    if i == 1
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
        flaDirect = mtb_list{3}(i);
        isDoubletOne = 1;
    end
    if isempty(strfind(mtb_list{2}{i}, flagName))
        flagName = regexprep(mtb_list{2}{i}, '_\d$', '');
        isDoubletOne = 1;
        flaDirect = mtb_list{3}(i);
    elseif str2double(regexp(mtb_list{2}{i}, '\d$', 'match')) ~= 1
        isDoubletOne = 0;
    end

    starFile = [starDir '/' mtb_list{2}{i} '.star'];
    docAlnFile = [docDir '/' docAlnPrefix mtb_list{1}{i} '.spi'];
    docRegFile = [docDir '/' docRegPrefix mtb_list{1}{i} '.spi'];
    disp(starFile);
    disp(docAlnFile);
    disp(docRegFile);
    origins = parse_star_file(starFile, 'origin');

    if isDoubletOne == 1
        docRegContent = parse_spider_doc(docRegFile);
    else
        docAlnContent = parse_spider_doc(docAlnFile);
        docRegContent = zeros(size(docAlnContent, 1), 11);
        docRegContent(:,1:7) = docAlnContent;
    end

    if (flaDirect == 1)
        origins = flipud(origins);
        docRegContent = flipud(docRegContent);
    end

    corr_origins = transform_pts(origins, docRegContent(:,1:7));

    if isDoubletOne == 1
        if docRegContent(1, 8) > 1
            proxLimit = -100000; % a very small number
        end
        for partId = 1:size(docRegContent,1)-1
            if (docRegContent(partId, 8) == docRegContent(partId + 1, 8))
                continue;
            else
                tmpPoint = matrix3_from_euler(docRegContent(partId+1, 1:3))*corr_origins(partId+1, :)';
                if docRegContent(partId, 8) == 1
                    proxLimit = tmpPoint(3);
                else
                    distLimit = tmpPoint(3);
                end
            end
        end
        if docRegContent(end, 8) < 3
            distLimit = 100000; % a very large number
        end
    else
        for partId = 1:size(corr_origins, 1)
            tmpPoint = matrix3_from_euler(docRegContent(partId, 1:3))*corr_origins(partId, :)';
            if tmpPoint(3) < proxLimit
                docRegContent(partId, 8) = 1;
            elseif tmpPoint(3) < distLimit
                docRegContent(partId, 8) = 2;
            else
                docRegContent(partId, 8) = 3;
            end
        end
        if flaDirect == 1
            docRegContent = flipud(docRegContent);
        end
        write_spider_doc(docRegContent, docRegFile);
    end
end

exit;
