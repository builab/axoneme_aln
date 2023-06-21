volFile = 'avg085CC.spi';
maskFile = 'mask_avg085CC.spi';

vol = tom_spiderread2(volFile);
img = vol.data;

g = fspecial('gaussian', 5, 4);
[m, n, p] = size(img);
mask = zeros(m, n, p);

for i = 1:p
    mask(:,:,i) = imfilter(img(:,:,i), g);
end

tom_spiderwrite2(maskFile, mask);