%-------------------------------------------------------------
% TEMPLATE
% @purpose Calculate weighted averages
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
avgFile = 'chlamy_avg.spi'; 
weightFile = 'weight_chlamy.spi';
corrAvgFile = 'chlamy_avg_cr.spi';

disp(['Average: ' avgFile])
disp(['Weight: ' weightFile])
disp(['Corrected Average: ' corrAvgFile])

calc_weighted_avg(avgFile, weightFile, corrAvgFile);
exit;
