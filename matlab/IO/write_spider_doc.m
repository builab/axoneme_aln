function write_spider_doc(array, output_file)
% WRITE_SPIDER_DOC
%		write_spider_doc(array, output_file)
%
% @date 29/08/2007

fid = fopen(output_file, 'w');

if size(array,3) > 1
	error('3d array not supported')
end

total_number = size(array, 1);
reg = size(array, 2);

% Print header
fprintf(fid, ' ;soc/spi %s %s\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'), output_file); 

for i = 1:total_number
	 fprintf(fid,'%5d %2d ', i, reg);
	 for j = 1:reg
	     fprintf(fid,'%12.5f ', array(i,j));
	 end
	 fprintf(fid,'\n');
end

fclose(fid);
