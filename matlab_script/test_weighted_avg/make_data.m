im_orig = tom_spiderread2('oda1_slice.spi');
im_orig = im_orig.data;
im_orig = vol2double(im_orig);
imwrite(im_orig, 'im_orig.png');

number_of_data = 200;

for i = 1:number_of_data
    im_name = ['im_'  sprintf('%0.3d', i) '.png'];
    im = im_orig + (2 + 3*rand(1,1))*randn(200,200);
    im = vol2double(im);
    imwrite(im, im_name);
end

% Read and average
im_avg = zeros(200,200);
for i = 1:number_of_data
    im_name = ['im_'  sprintf('%0.3d', i) '.png'];
    im = imread(im_name);
    im = im2double(im);
    im_avg = im_avg + im;
end

im_avg = vol2double(im_avg);
imwrite(im_avg, 'im_avg.png');

% Calculate weighted avg
im_wavg = zeros(200,200);
im_orig = im2double(imread('im_orig.png'));
im_orig_fil = tom_bandpass(im_orig, 1, 10, 3);
for i = 1:number_of_data
    im_name = ['im_'  sprintf('%0.3d', i) '.png'];
    im = imread(im_name);
    im = im2double(im);
    im_fil = tom_bandpass(im, 1, 10, 3);
    ccc = corr2(im_orig_fil, im_fil);
    disp([num2str(i) '--> ' num2str(ccc)])
    im_wavg = im_wavg + im*ccc;
end

im_wavg = vol2double(im_wavg);
imwrite(im_wavg, 'im_wavg.png');
