% Insert CCC to old document format

listFile = '/mol/ish/Data/Huy_tmp/chlamy/list_chlamy.txt';
docDir = '/mol/ish/Data/Huy_tmp/chlamy/doc';
docInputPrefix = 'doc_total_';
docOutputPrefix = 'doc_out_';

[mtb_list, number_of_records] = parse_list(listFile);


for i = 1:number_of_records
	docInputFile = [docDir '/' docInputPrefix mtb_list{1}{i} '.spi'];
	docOutputFile = [docDir '/' docOutputPrefix mtb_list{1}{i} '.spi'];
	disp(['Input: ' docInputFile]);
	disp(['Output: ' docOutputFile]);
	docInputContent = parse_spider_doc(docInputFile);
	number_of_particles = size(docInputContent, 1);
	outputContent = ones(number_of_particles, 7);
	outputContent(:,1:6) = docInputContent;
	write_spider_doc(outputContent, docOutputFile);
end

exit;
