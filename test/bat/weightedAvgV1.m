%-------------------------------------------------------------
% TEMPLATE
% @purpose Calculate weighted averages
% @version 1.0
% @date 20080301
%-------------------------------------------------------------
avgFile = 'chlamy_ida_v1_avg.spi'; 
weightFile = 'weight_chlamy_ida_v1.spi';
corrAvgFile = 'chlamy_ida_v1_avg_cr.spi';

disp(['Average: ' avgFile])
disp(['Weight: ' weightFile])
disp(['Corrected Average: ' corrAvgFile])

calc_weighted_avg(avgFile, weightFile, corrAvgFile);
exit;
