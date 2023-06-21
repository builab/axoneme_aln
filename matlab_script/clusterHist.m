%% --------------------------------------------------------------------------
%  Script: clusterHist.m
%  Purpose: histogram & text data of classification data
%  Date: 20090106
%% --------------------------------------------------------------------------

listFile = 'list_ADP.txt';
docPrefix = 'doc_class02_';
number_of_classes = 2;
outputFile = [docPrefix 'hist.txt'];

% ---- Program default ---------
docDir = 'doc';
% ------------------------------

[mtb_list, number_of_records] = parse_list(listFile);

% Initiate blank histogram
histo = cell(number_of_classes, 1);
for classId = 1:number_of_classes
	histo{classId} = zeros(60,1);
end

for doubletId = 1:number_of_records
	docFile = [docDir '/' docPrefix mtb_list{1}{doubletId} '.spi'];
    disp(docFile)
	
	% Reading
	docContent = parse_spider_doc(docFile);
	phi = docContent(1,1);
    if ((phi <= 180) && (phi > 0)) || ((phi < -180) && (phi >= -360))
		docContent = flipud(docContent);
    end

	for classId = 1:number_of_classes
        
        particleId = 1;
		while particleId <= size(docContent,1)               
			count = 0;
			if docContent(particleId, 8) == classId
				count = 1;
				doContinue = 1;
				while (doContinue && particleId < size(docContent, 1))
                    %disp(particleId)
					particleId = particleId + 1;                            
                    if docContent(particleId, 8) == classId
						count = count+1;
                    else						
						doContinue = 0;                        
                    end
                    
                end

                histo{classId}(count) = histo{classId}(count) + 1;
                if particleId == size(docContent,1)
                    break;
                end
                
            else
                particleId = particleId + 1;
            end
		end
    end
    
end


% Plot histogram
maxValue = max(histo{1});
for classId = 2:number_of_classes
    if maxValue < max(histo{classId});
        maxValue = max(histo{classId});
    end
end
for classId = 1:number_of_classes
    subplot(1, number_of_classes, classId)
    
    if sum(histo{classId}(21:60)) == 0
        bar(1:20, histo{classId}(1:20))
        axis([0 30 0 maxValue])
        title(['Histogram of class ' num2str(classId)])
    else
        bar(1:60, histo{classId}(1:60))
    end    
    set(gcf, 'Position', [560 305 1050 645]);
end

% write to file
fid = fopen(outputFile, 'wt');
for i = 1:60
    fprintf(fid, '%10d %10d %10d\n', i, histo{1}(i), histo{2}(i));
end
fclose(fid);

% Statistic
for classId = 1:number_of_classes
    clusterMean(classId) = sum(histo{classId}.*[1:60]')/sum(histo{classId});
end
