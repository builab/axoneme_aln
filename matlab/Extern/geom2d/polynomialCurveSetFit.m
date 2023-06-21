function coefs = polynomialCurveSetFit(seg, varargin)
%POLYNOMIALCURVESETFIT fit a set of polynomial curves to a segmented image
%
%   output = polynomialCurveSetFit(img)
%
%   Result is a cell array of matrices. Each matrix is DEG+1-by-2, and
%   contains coefficients of polynomial curve for each coordinate.
%
%   Example
%   fitcurveSet
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-03-21
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"

% default degree for curves
deg = 2;
if ~isempty(varargin)
    deg = varargin{1};
end


% ajoute un contour
seg([1 end], :) = 1;
seg(:, [1 end]) = 1;

% skeletise le segmentat
seg = bwmorph(seg, 'shrink', Inf);

% Trouve les points triples (en tant qu'image)
imgNodes = imfilter(double(seg), ones([3 3])).*seg > 3;

lblNodes = bwlabel(imgNodes, 4);
struct   = regionprops(lblNodes, 'Centroid');
nodes = zeros(length(struct), 2);
for i=1:length(struct)
    nodes(i, 1:2) = struct(i).Centroid;
end

% enleve les bords de l'image
seg([1 end], :) = 0;
seg(:, [1 end]) = 0;

% Isoles les branches
imgBranches = seg & ~imgNodes;
lblBranches = bwlabel(imgBranches, 8);

% % donne une couleur a chaque branche, et affiche
% map = colorcube(max(lblBranches(:))+1);
% rgbBranches = label2rgb(lblBranches, map, 'w', 'shuffle');
% imshow(rgbBranches);

% init
nBranches = max(lblBranches(:));
xcs = zeros(nBranches, deg+1);
ycs = zeros(nBranches, deg+1);
curves  = cell(nBranches, 1);

% Pour chaque branche, trouve un polynome d'approximation
for i=1:nBranches
    disp(i);
    imgBranch = lblBranches == i;
    
    % points du contour
    points = chainPixels(imgBranch);
    
    % verifie qu'on a assez de points
    if size(points, 1)<max(deg+1-2, 2)
        % find labels of nodes
        inds = unique(lblNodes(imdilate(imgBranch, ones(3,3))));
        inds = inds(inds~=0);
        
        if length(inds)<2
            disp(['Could not find extremities of branch number ' num2str(i)]);
            continue;
        end
        
        % consider extremity nodes
        node0 = nodes(inds(1),:);
        node1 = nodes(inds(2),:);
        
        % use only a linear approximation
        xc = zeros(1, deg+1);
        yc = zeros(1, deg+1);
        xc(1) = node0(1);
        yc(1) = node0(2);
        xc(2) = node1(1)-node0(1);
        yc(2) = node1(2)-node0(2);
        
        % assigne au tableau de courbes
        xcs(i,:) = xc;
        ycs(i,:) = yc;
        
        % next branch
        continue;
    end

    % trouve le noeud le plus proche du premier point
    [dist, ind0] = minDistancePoints(points(1, :), nodes);
    [dist, ind1] = minDistancePoints(points(end, :), nodes);
    
    % ajoute les deux noeuds aux extremites du point.
    points = [nodes(ind0,:); points; nodes(ind1,:)];
    
    % paramtetrization de la polyline
    t = parametrize(points);
    t = t/max(t);
    
    % calcule un polynome d'approximation
    [xc yc] = polynomialCurveFit(...
        t, points, deg, ...
        0, {points(1,1) points(1,2)},...
        1, {points(end,1), points(end,2)});
    
    % assigne au tableau de courbes
    xcs(i,:) = xc;
    ycs(i,:) = yc;
end

% cree une courbe discrete pour chaque courbe polynomiale
coefs = cell(1, nBranches);
for i=1:nBranches
%     if sum(xcs(i,:))==0
%         curves{i} = [0 0;0 0];
%         continue;
%     end
% %     curves{i} = polynomialCurvePoint(linspace(0, 1, 100)', xcs(i,:), ycs(i,:));
    coefs{i} = [xcs(i,:);ycs(i,:)];
end

% % affiche image segmentee d'un cote, et image des courbes de l'autre
% figure;
% subplot(121);
% imshow(~imgBranches);
% subplot(122);
% imshow(ones(size(imgBranches)));
% hold on;
% for i=1:nBranches
%     drawCurve(curves{i});
% end
% 
% % affiche en surimpression sur l'image d'origine
% figure,
% imshow(img);
% hold on;
% for i=1:nBranches
%     drawCurve(curves{i}, 'linewidth', 2, 'color', 'r');
% end


function points = chainPixels(img, varargin)
%CHAINPIXELS return the list of points which constitute a curve on image
%   output = linkPixels(input)
%
%   Example
%   linkPixels
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2007-03-21
% Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.
% Licensed under the terms of the LGPL, see the file "license.txt"


conn = 8;
if ~isempty(varargin)
    conn = varargin{1};
end

% matrice de voisinage
if conn==4
    f = [0 1 0;1 1 1;0 1 0];
elseif conn==8
    f = ones([3 3]);
end

% find extremity points
nb = imfilter(double(img), f).*img;
imgEnding = nb==2 | nb==1;
[yi xi] = find(imgEnding);

% extract coordinates of points
[y x] = find(img);

% index of first point
if isempty(xi)
    % take arbitrary point
    ind = 1;
else
    ind = find(x==xi(1) & y==yi(1));
end

% allocate memory
points  = zeros(length(x), 2);

if conn==8
    for i=1:size(points, 1)
        % avoid multiple neighbors (can happen in loops)
        ind = ind(1);
        
        % add current point to chained curve
        points(i,:) = [x(ind) y(ind)];

        % remove processed coordinate
        x(ind) = [];    y(ind) = [];

        % find next candidate
        ind = find(abs(x-points(i,1))<=1 & abs(y-points(i,2))<=1);
    end
else
    for i=1:size(points, 1)
        % avoid multiple neighbors (can happen in loops)
        ind = ind(1);
        
        % add current point to chained curve
        points(i,:) = [x(ind) y(ind)];

        % remove processed coordinate
        x(ind) = [];    y(ind) = [];

        % find next candidate
        ind = find(abs(x-points(i,1)) + abs(y-points(i,2)) <=1 );
    end
end    
