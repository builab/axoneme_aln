%% --------------------------------------------------------------------------
%  Script: plotListFlagellaAln.m
%  Purpose: plotting all flagella from a list with vanadate and non-nucleotide coloring differently with vertical alignment
%  Date: 20081220
%% --------------------------------------------------------------------------

listFile = 'list_wt_van.txt';
docPrefix = 'doc_class4_';
flagellaList = {'wt_van_01', 'wt_van_02', 'wt_van_03', 'wt_van_04', 'wt_van_05', 'wt_van_06', 'wt_van_07'};


for i = 1:numel(flagellaList)
	flagellaName = flagellaList{i};
	disp(flagellaName)
	plotFlagellaAln
end
