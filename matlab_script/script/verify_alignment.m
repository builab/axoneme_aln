function [residual_table, avg_std] = verify_alignment(star_file, aln_file, output, limit_factor, pixel_size, period)
% VERIFY ALIGNMENT verify the periodicity of particle after alignment
% [residual_table, avg_std] = verify_alignment(star_file, aln_file, output_file, limit_factor, pixel_size, period)
% @author HB
% @date 26/09/2007
% @lastmod 20071008 sort star file before calculate distance

fid = fopen([output '_verf.yuh'], 'wt');

output_tit = strrep(output, '_', '\_');

unix(['cat ' star_file ' | grep ''^[[:space:]]*[0-9]''  > star.txt']);
unix(['cat ' aln_file ' | grep ''^[[:space:]]*[0-9]''  > aln.txt']);

% Read aln_file
star_content = load('star.txt');
aln_content = load('aln.txt');

origin = star_content(:,3:5);
transform = aln_content(:,3:8);

origin_new = zeros(size(origin));

% Calculate new_origin
for j = 1:size(origin, 1)
    euler = transform(j,1:3);
    rev_euler = [-euler(3) -euler(2) -euler(1)];
    shift = transform(j,4:6);
    mat = matrix3_from_euler(rev_euler);
    origin_sh01 = -shift;
    origin_rt01 = mat*origin_sh01'; % reverse rotation
    origin_new(j,:) = origin_rt01' + origin(j,:); % shift back
end

% Sort origin file in y direction
[oy_s, sort_indx] = sort(origin(:,2));
origin_sorted = origin(sort_indx,1:3);
origin_new_sorted = origin_new(sort_indx, 1:3);


% Calc distance
distance  = [0 sqrt(sum((diff(origin_sorted, 1, 1)).^2,2))']';
distance_aln = [0 sqrt(sum((diff(origin_new_sorted, 1, 1)).^2,2))']';
line_period = period*ones(size(origin,1),1);

% Statistical calculation
limit = limit_factor * period;
residual_err = pixel_size*distance;
indx_limit = residual_err < limit;
residual_err = rem(residual_err, period);

% Corrected for near optimuc
indx_pos = find(residual_err/period > 0.5);
residual_err(indx_pos) = residual_err(indx_pos) - period;
indx_neg = find(residual_err/period < -0.5);
residual_err(indx_neg) = residual_err(indx_neg) + period;

avg_err = mean(residual_err(indx_limit));
std_err = std(residual_err(indx_limit));

residual_err_aln = pixel_size*distance_aln;
residual_err_aln = rem(residual_err_aln, period);

indx_pos = find(residual_err_aln/period > 0.5);
residual_err_aln(indx_pos) = residual_err_aln(indx_pos) - period;
indx_neg = find(residual_err_aln/period < -0.5);
residual_err_aln(indx_neg) = residual_err_aln(indx_neg) + period;

avg_err_aln = mean(residual_err_aln(indx_limit));
std_err_aln = std(residual_err_aln(indx_limit));

residual_table = [residual_err' ; residual_err_aln' ; angle_xy']';
avg_std = [avg_err std_err ; avg_err_aln std_err_aln];

% Plot periodicity graph
figure,
set(gcf,'Unit', 'normalized', 'Position', [0 0 .6 .3], 'Resize', 'off');
subplot(1,2,1)
plot(residual_err(indx_limit) + period, '+b');
hold on
plot(line_period, 'r', 'LineWidth', 2);
ht1 = text(5,period+200, ['avg err +/- std err (pixels): ' num2str(avg_err/pixel_size) ' +/- ' num2str(std_err/pixel_size)]);
set(ht1, 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'blue');
title(['Original distance for ' output_tit], 'FontWeight', 'bold', 'FontSize', 10);
ylabel('Distance to the next center (Angstrom)', 'FontWeight', 'bold', 'FontSize', 10);
xlabel('Particle number', 'FontWeight', 'bold', 'FontSize', 10)
set(gca, 'FontWeight', 'bold', 'FontSize', 10);
axis([0 55 period-240 period+240]);
hold off

subplot(1,2,2)
plot(residual_err_aln(indx_limit) + period, '+b');
hold on
plot(line_period, 'r', 'LineWidth', 2);
ht2 = text(5,period+200, ['avg err +/- std err (pixels): ' num2str(avg_err_aln/pixel_size) ' +/- ' num2str(std_err_aln/pixel_size)]);
xlabel('Particle number', 'FontWeight', 'bold', 'FontSize', 10)
set(ht2, 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'blue');
title(['Distance after aligned for ' output_tit], 'FontWeight', 'bold', 'FontSize', 10)
set(gca, 'FontWeight', 'bold', 'FontSize', 10);
axis([0 55 period-240 period+240]);
hold off
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, '-r0', [output '.tif'], '-dtiff');

%%%%%%%%%%%%%%%%%%%%%%%%
% Plot phi & theta & psi
%%%%%%%%%%%%%%%%%%%%%%%%

indx = find(transform >= 180);
transform(indx) = transform(indx) - 360;
indx2 = find(transform < -180);
transform(indx2) = transform(indx2) + 360;

figure,
set(gcf,'Unit', 'normalized', 'Position', [0 0 .6 .3]);
subplot(1,2,1)
plot(transform(:,1)', transform(:,2)', 'r*');
hold on
plot(-180:180, zeros(1,361), 'b', 'LineWidth', 1)
plot(zeros(1,361), -180:180, 'b', 'LineWidth', 1)
hold off
axis([-180 180 -180 180]);
title(['Phi vs. Theta (' output_tit ')'] , 'FontWeight', 'bold')
xlabel('Phi', 'FontWeight', 'bold')
ylabel('Theta', 'FontWeight', 'bold')

subplot(1,2,2)
plot(transform(:,3)', transform(:,2)', 'bo');
hold on
plot(-180:180, zeros(1,361), 'b', 'LineWidth', 1)
plot(zeros(1,361), -180:180, 'b', 'LineWidth', 1)
axis([-180 180 -180 180]);
title(['Psi vs. Theta (' output_tit ')'], 'FontWeight', 'bold');
xlabel('Psi', 'FontWeight', 'bold')
ylabel('Theta', 'FontWeight', 'bold')
hold off
set(gcf, 'PaperPositionMode', 'auto');
print(gcf, '-r0', ['rotang_' output '.tif'], '-dtiff');


% Write to output
fprintf(fid, '\n#Parameters\n');
fprintf(fid, 'Pixel size  : %4.2f (A)\n', pixel_size);
fprintf(fid, 'Periodicity : %4d (A)\n', period);
fprintf(fid, 'Max. dis. lim.: %4d (A)\n', limit);

fprintf(fid, '\n#%s\n', output);
fprintf(fid, 'Star file: %s\n', star_file);
fprintf(fid, 'Doc. file: %s\n\n', aln_file);
fprintf(fid, '#%3s %7s %7s %7s %7s %7s %7s %7s %7s %7s %7s %7s\n', 'No.','Org_ox', 'Org_oy', 'Org_oz', 'Aln_ox', 'Aln_oy','Aln_oz', 'D.(px)', 'A.D(px)', 'Res.(A)', 'A.Res(A)', 'Limit(px)');

for j = 1:size(origin,1)
    if j == size(origin, 1)
        fprintf(fid, ' %3d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n', j, origin(j,1), origin(j,2), origin(j,3), origin_new(j,1), origin_new(j,2), origin_new(j,3), 0, 0, 0, 0, 0);
    else
        fprintf(fid, ' %3d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f\n', j, origin(j,1), origin(j,2), origin(j,3), origin_new(j,1), origin_new(j,2), origin_new(j,3), distance(j,1), distance_aln(j,1), residual_err(j,1), residual_err_aln(j,1), indx_limit(j,1));
    end
end
fprintf(fid, '\n#Residual Summary\n');
fprintf(fid, 'Original Res. Error Avg. +/- Std (pixel): %6.4f +/- %6.4f\n', avg_err/pixel_size, std_err/pixel_size);
fprintf(fid, 'Aligned Res. Error Avg. +/- Std (pixel): %6.4f +/- %6.4f\n', avg_err_aln/pixel_size, std_err_aln/pixel_size);

fclose(fid);
