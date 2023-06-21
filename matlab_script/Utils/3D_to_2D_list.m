%---------------------------------------------------------------------
% Script
% @purpose Display 3D particle projection in Z direction into 2D image
% @date 20080411
%---------------------------------------------------------------------

listFile =  '/mol/ish/Data/Huy_tmp/oda1hm_auto/list_oda1hm.txt.bak';
dataDir = '/mol/ish/Data/Huy_tmp/oda1hm';

[mtb_list, number_of_records] = parse_list(listFile);

for i = 1:number_of_records
	fileName = [dataDir '/' regexprep(mtb_list{1}{i}, '(_\d+)$', '_rough$1') '.spi'];
	disp(fileName)
	vol = tom_spiderread2(fileName);
	im = sum(vol.data, 3);
%	figure, imshow(im, [])
%	title(strrep(mtb_list{1}{i}, '_', '\_'))
%	pause(3)
	imwrite(vol2double(im), [mtb_list{1}{i} '.png']);
end
