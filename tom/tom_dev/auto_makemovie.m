list = {'ATpgase_05avg03_mt7.spi', 'ATpgase_05avg03_mt8.spi', 'ATPgase_05avg03_mt9.spi', 'ATPgase_5avg03_mt3.spi', 'ATPgase_5avg03_mt4.spi', 'ATPgase_5avg03_mt5.spi', 'ATPgase_5avg03_mt6.spi'}

for i = 1:length(list)
	filename = list{i};
   moviefile = strcat(substring(filename,0,length(filename)-4),'avi');
	in = tom_spiderread2(filename);
	minv = min(min(min(in.data)));
	maxv = max(max(max(in.data)));
	tom_makemovie(in.data, moviefile, 25, 100, [minv maxv], 1);
end
