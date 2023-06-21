function model = draw_flagella_model(flagellaModel, doublet_list, flagName, outputImage, outputImageCs, doOutputInfo)
% DRAW_FLAGELLA_MODEL drawing the flagella model
%   draw_flagella_model(flagellaModel, doublet_list, flagName, pixelSize, outputImage, outputImageCs)
% Parameters
%  INPUT
%	flagellaModel 	output from flagella_model function
%   doublet_list    doublet list
%   flagName        flagella Name
%   pixelSize       Pixel size of the data
%   outputImage		Image (tiff format) of the model
%   outputImageCs   Image (tiff format ) of the model
%   doOutputInfo    0 or 1 (if 1, ellipse is fitted on the cross section)
%  OUTPUT
%   model contain a and b axis of ellipse
% HB 20110102

if (nargin < 6)
    doOutputInfo = 0;
end

figure,

cuttingPoints = [];

xLimit = 0;
yLimit = 0;
zLimit = 0;

maxCurv = 0;

for doublet_id = doublet_list
    origins = flagellaModel(doublet_id).OrigPoints;
    smoothen_origins = smoothen_line(origins, flagellaModel(doublet_id).SmoothingLimit , flagellaModel(doublet_id).SortDim);
    oxyzi = flagellaModel(doublet_id).Line;
    if xLimit < max(origins(:,1))
        xLimit = max(origins(:,1));
    end
    if yLimit < max(origins(:,2))
        yLimit = max(origins(:,2));
    end
    if zLimit < max(origins(:,3))
        zLimit = max(origins(:,3));
    end
    cuttingPoints = [cuttingPoints; oxyzi(flagellaModel(doublet_id).CutPoint, :)];

    if maxCurv < max(flagellaModel(doublet_id).Curvature)
	maxCurv = max(flagellaModel(doublet_id).Curvature);
    end    

    plot3(smoothen_origins(:,1), smoothen_origins(:,2), smoothen_origins(:,3), 'b.')
    hold on
    plot3(oxyzi(:,1), oxyzi(:,2), oxyzi(:,3), 'r')
    hold on
    box on
end

if xLimit < yLimit
    xLimit = yLimit;
else
    yLimit = xLimit;
end

plot3(cuttingPoints(:,1), cuttingPoints(:,2), cuttingPoints(:,3), 'ro-');
axis equal
axis([0 xLimit 0 yLimit 0 zLimit]);
view(10, 80);
title(['Model of ' strrep(flagName, '_', '\_')], 'FontWeight', 'Bold', 'FontSize', 14);
if (doOutputInfo)
	text(xLimit/2, yLimit/2, 0, ['Maximum curvature ' num2str(maxCurv*10^3) 'um-1'], 'FontSize', 12, 'FontWeight', 'Bold');
end
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, '-r0', outputImage, '-dtiff');
close(gcf)


pixelSize = flagellaModel(doublet_list(1)).PixelSize;
mtbRadius = round(10/pixelSize);

% Drawing the cross section
tfmCuttingPoints = zeros(length(doublet_list), 2); 
figure,
for i = 1:length(doublet_list)
    doublet_id = doublet_list(i);
    % Nearest neighbor interpolation
    %dist_array = sum((repmat(cuttingPoints(i, :), size(flagellaModel(doublet_id).OrigPoints, 1), 1) - flagellaModel(doublet_id).OrigPoints).^2, 2);
    %[min_dis, min_ind] = min(dist_array);
    mat = matrix3_from_euler([flagellaModel(doublet_id).RotAng(1:2) 0]);
    %mat = matrix3_from_euler([flagellaModel(doublet_id).IndRotAng(min_ind, 1:2) 0]);
    pts_tfm = (mat*cuttingPoints(i, :)')';
    %disp_v = [sin(flagellaModel(doublet_id).IndRotAng(min_ind, 3)*pi/180) -cos(flagellaModel(doublet_id).IndRotAng(min_ind, 3)*pi/180)];
    disp_v = [sin(flagellaModel(doublet_id).RotAng(3)*pi/180) -cos(flagellaModel(doublet_id).RotAng(3)*pi/180)];
    tfmCuttingPoints(i,:) = pts_tfm(1:2);
    
    % Calculating length of vector to display
    plot([pts_tfm(1) pts_tfm(1)+ 2*mtbRadius*disp_v(1)], [pts_tfm(2) pts_tfm(2) + 2*mtbRadius*disp_v(2)], 'b-');
    text(pts_tfm(1) + 10, pts_tfm(2) + 10, num2str(doublet_id))
    hold on
    % origin of mtb A
    originA = [pts_tfm(1)+round(mtbRadius/2)*disp_v(1) pts_tfm(2) + round(mtbRadius/2)*disp_v(2)];
    originB = [pts_tfm(1)-mtbRadius*disp_v(1) pts_tfm(2)-mtbRadius*disp_v(2)];
    h1 = ellipsedraw(mtbRadius, mtbRadius, originA(1), originA(2), 0, 'r-');
    set(h1, 'LineWidth', 2)
    hold on
    h2 = ellipsedraw(mtbRadius, mtbRadius, originB(1), originB(2), 0, 'r-');
    set(h2, 'LineWidth', 2)
    hold on
    axis equal
end

if length(doublet_list) == 9
    if (doOutputInfo)    
        elli = fit_ellipse(tfmCuttingPoints(:,1), tfmCuttingPoints(:,2), gca);
   	if (elli.a > elli.b) 
		tmp = elli.a;
		elli.a = elli.b;
		elli.b = tmp;
	end
	if ~isempty(elli.a)
            text(mean(tfmCuttingPoints(:,1))-mtbRadius*3, mean(tfmCuttingPoints(:,2)), 'Ellipse fit', 'FontWeight', 'bold');
            text(mean(tfmCuttingPoints(:,1))-mtbRadius*3, mean(tfmCuttingPoints(:,2))-mtbRadius,    ['a = ' num2str(elli.a)])
            text(mean(tfmCuttingPoints(:,1))-mtbRadius*3, mean(tfmCuttingPoints(:,2))-2*mtbRadius, ['b = ' num2str(elli.b)])
            text(mean(tfmCuttingPoints(:,1))-mtbRadius*3, mean(tfmCuttingPoints(:,2))-3*mtbRadius, ['ratio = ' num2str(elli.b/elli.a)])
        end
    else
        elli = fit_ellipse(tfmCuttingPoints(:,1), tfmCuttingPoints(:,2));
    end
end

if exist('elli', 'var')
	model = [elli.a elli.b];
end

title(['Cross section model of ' strrep(flagName, '_', '\_')], 'FontWeight', 'Bold', 'FontSize', 14);
xlabel('Z direction (high Z to low Z)')
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, '-r0', outputImageCs, '-dtiff');
close(gcf)



