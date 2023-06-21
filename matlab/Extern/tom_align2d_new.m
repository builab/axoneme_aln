function [translation_out,rotation_out,deltas,moved_part]=tom_align2d_new(in_region,ref_region,region,translation_max,iterations, rotation_limit)

% 2d Alignment of 2 particles by rotation and translation 
%
%   INPUT:  in_region: subregion containing the particle which is big enough
%                      to rotate the particle inside the subregion without loosing edges 
%           ref_region: region containing the particle to which the particle in in_region 
%                       should be aligned  
%           region: size of the particle
%           translation_max: threshold for max translation
%           iterations: number of alignments
%			rotation_limit: limit of rotation angle 
%   
%   OUTPUT: tranlation: Translation Vector 
%           ratation: rotation in degree
%           deltas: [rotation translationX translationY] rotation and translation needed 
%           to align the particle after the last iteration. This values can be used as a
%           measure the quality of the alignment.   
%
%  Example: [trans,rot,delta,moved_part]=tom_align2d(in_region,ref,64,5,10, [-60 60])
%
%  22/11/03 SN, 24/11/03 tested and bug fixed FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom
%
% HB 20080308 modified to take a limit of rotation angle



rotation_out=0;
translation_out=[0 0];
deltas=[0 0 0];

    region_start=size(in_region,1)./2-region./2;
    region_end=size(in_region,1)./2+region./2;
    in = in_region(region_start+1:region_end,region_start+1:region_end);
    region_ref_start=size(ref_region,1)./2-region./2;
    region_ref_end=size(ref_region,1)./2+region./2;
    ref=ref_region(region_ref_start+1:region_ref_end,region_ref_start+1:region_ref_end);    

for lauf=1:iterations

    in_polar = tom_cart2polar(in);    
    ref_polar = tom_cart2polar(ref); 
    % smooth borders a little bit for correlation
    % in_polar=tom_smooth(in_polar,4);
    % ref_polar=tom_smooth(ref_polar,4);
    % rotation correlation 
    fft_in_polar=fft2(in_polar);
    fft_ref_polar=fft2(ref_polar);
    rotation_xcorr=real(fftshift(ifft2(fft_ref_polar.*conj(fft_in_polar))));
	x_limit = round((180 - rotation_limit)./360.*size(in_polar, 2) + 1);	
    rotation_peak=tom_peak(rotation_xcorr, [min(x_limit) max(x_limit) 1 size(in_polar,1)]);
	
    % calculate angle
    rotation=(180-(360./size(in_polar,2).*(rotation_peak(2)-1)));
    
    % rotate particle
    in_region_rotated=imrotate(in_region,-rotation,'bilinear','crop');
 
    % box out inner part of larger image
    in_rotated=in_region_rotated(region_start+1:region_end,region_start+1:region_end);
    % translation correlation 
    fft_ref=fft2(ref);
    fft_in_rotated=fft2(in_rotated);
    translation_xcorr=real(fftshift(ifft2(fft_ref.*conj(fft_in_rotated))));
    translation_peak=tom_peak(translation_xcorr);
    translation=(translation_peak-size(in_rotated,1)./2);
    % Calculate Output Values
    rotation_out=rotation_out+rotation;
    translation_out=translation_out+(translation-1);
    
    if (abs(translation)-1<=translation_max)
        in_region_rotated_translated=tom_move(in_region_rotated,translation-1);
        in_region = in_region_rotated_translated;
        in = in_region(region_start+1:region_end,region_start+1:region_end);
        
        deltas(1)=rotation;
        deltas(2)=translation(1)-1;
        deltas(3)=translation(2)-1;
    else
        deltas(1)=rotation;
        deltas(2)=translation_max+1;
        deltas(3)=translation_max+1;
        moved_part=in;
        return;
    end
end

    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Problem
    % ???
    % rotation_out=rotation_out+1;


moved_part=in;


    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

