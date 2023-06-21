% --------------------------------------
%	Script to combine 4 96nm doc to a 24nm doc
%
% --------------------------------------

listFile = '/mol/ish/Data/Huy_tmp/oda4_new/list_oda4.txt';
docDir = '/mol/ish/Data/Huy_tmp/oda4_new/doc';
starDir = '/mol/ish/Data/Huy_tmp/oda4_new/star';
docInputPrefix = 'doc_total_';
docOutputPrefix = 'doc_total_';

[mtb_list, number_of_records] = parse_list(listFile);


for i = 1:number_of_records
        docOutputFile = [docDir '/' docOutputPrefix mtb_list{1}{i} '.spi'];
        starOutputFile = [starDir '/' mtb_list{2}{i} '.star'];
        disp(['Output: ' docOutputFile]);
		disp(['Output: ' starOutputFile]);

		% Read in
		number_of_particles = 0;
		for varId = 1:4				
				varStr = ['ida_v' num2str(varId)];
		        docInputFile = [docDir '/' docInputPrefix regexprep(mtb_list{1}{i}, '(\d\d\d)$', [varStr '_$1']) '.spi'];
				starFile = [starDir '/' mtb_list{2}{i} sprintf('ida_v%d', varId) '.star'];
				disp(['Reading: ' docInputFile]);
				disp(['Reading: ' starFile]);
				docInputContent = parse_spider_doc(docInputFile);
				starInputContent = parse_star_file(starFile);
				starInputContent = starInputContent(:,3:5);
				number_of_particles = number_of_particles + size(docInputContent, 1);
				if (varId == 1) 
					docOutputContent = docInputContent;
					starOutputContent = starInputContent;
				else
					docOutputContent = [docOutputContent; docInputContent];
					starOutputContent = [starOutputContent; starInputContent];
				end
		end

		[sort_origin_y, sort_indx] = sort(starOutputContent(:,2), 'ascend');
		starOutputContent = starOutputContent(sort_indx, :);
		docOutputContent = docOutputContent(sort_indx, :);
			
       
        write_spider_doc(docOutputContent, docOutputFile);
		write_star_file(starFile, round(starOutputContent), starOutputFile);
end

exit;
