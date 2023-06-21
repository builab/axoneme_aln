function [max_ccf,max_angle]=tom_max_ccf_of_angle(pic,mask,num_of_angles,peak_size_Xcorr_polar)
%
% 
% This function rotates the mask and calculates the max cross correlation between the mask and
% the image.   
% 
% INPUT:   pic: image for which the correlation should be calculated
%          mask: mask which is correlated with the picture.
%          num_of_angles: number of angles the mask should be rotated
%          peak_size_Xcorr_polar:delta of angles 
%
%                       
% OUTPUT:  max_ccf: image representing the maximum cross correlation
%          coefficient for the scanned angles.
%          max_angle: image representing the angles for max of the cross correlation     
%
% FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


pic_size=size(pic,1);

% transform into polar coord
mask_polar = tom_cart2polar(mask);    
pic_polar = tom_cart2polar(pic); 

% make coorrelation in polar coord to get the angles
fft_mask_polar=fft2(mask_polar);
fft_pic_polar=fft2(pic_polar);
rotation_xcorr=real(fftshift(ifft2(fft_mask_polar.*conj(fft_pic_polar))));


% get the first num_of_angeles Angles 
rad=peak_size_Xcorr_polar;
[coord val m]=tom_peak(rotation_xcorr,rad);
rot_peak(1)=(180-(360./size(pic_polar,2).*(coord(2)-1)));
for i=2:num_of_angles
    [coord val m]=tom_peak(m,rad);
    rot_peak(i)=(180-(360./size(pic_polar,2).*(coord(2)-1)));
end;

%rotate Mask and Correlate with the Picture
max_ccf= zeros(pic_size,pic_size);
max_angle= zeros(pic_size,pic_size);
fprintf('max_ccf',i);
for i= 1:num_of_angles
    rotated_mask=imrotate(mask,-rot_peak(i),'bilinear','crop');
    corr_pic=tom_korr(rotated_mask,pic,'xcf');
    new_ccf=corr_pic;
    new_angle=rot_peak(i);
    max_ccf = (max_ccf>new_ccf).*max_ccf + (max_ccf<=new_ccf).*new_ccf;
    max_angle= (max_ccf>new_ccf).*max_angle + (max_ccf<=new_ccf).*new_angle;
    fprintf('.');
end;
fprintf('done \n');
fprintf('number of angles: %d \n',i);



