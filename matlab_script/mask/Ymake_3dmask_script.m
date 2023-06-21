%%-------------------------------------------------------
% Script: make_3dmask.m
% @purpose Create 3d mask from a 2d mask
% @date 20080516
%%-------------------------------------------------------

%-------------- TO CHANGE -------------------------------

input2dfile = 'trypanosoma_rs_RSP3_2d.png';
output3dfile = 'trypanosome_rs_RSP3_3dmask.spi';

%-------------- DON'T CHANGE AFTER ----------------------

im = imread(input2dfile);
if size(im, 3) == 1
    im = imread(input2dfile);
else
    im = im(:,:,1);
end
bw = im > .001;
bw2 = bwmorph(bw, 'close',2);
g = fspecial('gaussian', 5, 4);
im2 = imfilter(double(bw2), g);
%im2 = flipud(im2);
[m, n] = size(im);
mask = zeros(m, n, m);

for i = 1:m
    mask(i,:,:)  = im2;
end

%tom_dspcub(mask, 0);
tom_spiderwrite2(output3dfile, mask);
