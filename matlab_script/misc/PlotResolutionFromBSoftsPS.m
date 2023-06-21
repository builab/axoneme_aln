% open the file containing the resolution test data
in_file = fopen('resultBresolve_tightmasked20.ps', 'r');
 
if (in_file == -1) 
    error('ERROR: File not found.'); 
end 

% read all the lines till data starts
line = '';
while (isempty(regexpi(line,'/Data*'))),
    line = fgets(in_file);
    %disp(line);
end;
line = fgets(in_file);

[data, count] = fscanf(in_file, ['%f %f %f'], [3 inf]); 

data = data';

x = data(:,1);
f=figure;

plot(x,data(:,2),'LineWidth',2); % PLOT ITSELF
hold on
plot([0, 1/42.86, 1/42.86],[0.5, 0.5, 0.0], 'color',[.3,.3,.3],'LineStyle','--','LineWidth',1);
hold off

%title('Model resolution','FontSize',20)
xlabel('Resolution (A)','FontSize',16);
ylabel('FSC','FontSize',16);

set(gca,'XLim',[0, max(x)],'YLim',[0, 1]); % remove empty space on the right of the plot
set(gca,'XTick',0:max(x)/10:max(x));       % do ticks as in the original PS-file (at 0 and 10 more)
set(gca,'XTickLabel',{'Inf', '198.8','99.4','66.3','49.7','39.8', '33.1', '28.4', '24.8', '22.1', '19.9'},'FontSize',14);

text(1/42.86,0.525,' 42.86', 'HorizontalAlignment','left','FontSize',16)

saveas(f,'PlotFSC_tight20.pdf');
