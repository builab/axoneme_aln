function [coord_out,avg]=tom_find_particle_2d(pic,mask,particle_mask,avg,max_ccf_of_angles_param,filter_max_ccf_param,fine_align_parameter)
%
% finds particles in a picture 
% 
%  Syntax:
%  [coord_out,avg]=tom_find_particle_2d(pic,mask,particle_mask,avg,max_ccf_of_angles_param,filter_max_ccf_param,fine_align_parameter)
%
%   INPUT:  pic: picture where the particles should be found
%           mask: mask with the same size as the picture containing the particle 
%           particle_mask: mask with the size of the particle
%           avg: average
%           max_ccf_of_angles_param: parameters for creating the max_ccf function 
%           filter_max_ccf_param:parameters for filtering the max_ccf function 
%           fine_align_parameter: parameters needed for 2d alignment
%
%   OUTPUT: coord_out: array containing the x,y coordinates and the angle of every particle 
%           avg: average of all particles
%           
%  Example:
%  [coord_out avg]=tom_find_particle_2d(pic,mask,particle_mask,avg,max_ccf_of_angles_param,filter_max_ccf_param,fine_align_parameter);
%
%  10/12/2003 FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom



num_of_angles=max_ccf_of_angles_param(1);
kill_max_Xpolar=max_ccf_of_angles_param(2);

[max_ccf,max_angle]=tom_max_ccf_of_angle(pic,mask,num_of_angles,kill_max_Xpolar);
   
%debug staff
%save max_ccf;
%save max_angle;
%load max_ccf;
%load max_angle;


% find the first n peaks in max_ccf
num_of_particles=filter_max_ccf_param(1);
kill_max_ccf=filter_max_ccf_param(2);

[coord val m]=tom_peak(max_ccf,kill_max_ccf);
peaks(1,1)=coord(1);
peaks(1,2)=coord(2);

%figure; tom_imagesc(pic);drawnow; set(gcf,'DoubleBuffer','on');  

for i=2:num_of_particles
    [coord val m]=tom_peak(m,kill_max_ccf);
    peaks(i,1)=coord(1);
    peaks(i,2)=coord(2);
    hold on;
    %plot(coord(1),coord(2),'ro'); drawnow; set(gcf,'DoubleBuffer','on');  
end;


% fine alignment
%avg=particle_mask;
particle_rad=fine_align_parameter(1);
iterations=fine_align_parameter(2);
thres= [fine_align_parameter(3) fine_align_parameter(4) fine_align_parameter(5) fine_align_parameter(6)];  
number=0;
avg=zeros(particle_rad*2,particle_rad*2);


fprintf('fine alignment',i);
for i=1:num_of_particles
    
    %check if its poosible to box out the particle
    if ( ((peaks(i,1)-particle_rad*2) > 1) & ((peaks(i,1)+particle_rad*2-1) < size(pic,1)) ...
            & ((peaks(i,2)-particle_rad*2) > 1) & ((peaks(i,2)+particle_rad*2-1) < size(pic,1)) ) 
        
        %box out the particle
        in_region=pic((peaks(i,1)-particle_rad*2):(peaks(i,1)+particle_rad*2-1),(peaks(i,2)-particle_rad*2):(peaks(i,2)+particle_rad*2-1));
        
        %rotate particle to max_angle
        rotated_region=imrotate(in_region,max_angle(peaks(i,1),peaks(i,2)),'bilinear','crop');
        
        %make a 2d alignmet
        [trans,rot,delta,moved_part]=tom_align2d(rotated_region,particle_mask,particle_rad*2,thres(4),iterations);
        
        if (  ( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)) )
            %calculate avg
            moved_part_norm=(moved_part-mean2(moved_part))./abs(mean2(moved_part));   
            avg=avg+moved_part_norm;
            %calculate refined coordinates
            number=number+1;  
            coord_out(number,1)=peaks(i,1)+trans(1);     
            coord_out(number,2)=peaks(i,2)+trans(2);
            coord_out(number,3)=max_angle(peaks(i,1),peaks(i,2))+rot;    
        end;
        %particle_mask=avg;
    end;
   fprintf('.');
end;
if (number==0)
    avg=particle_mask;
    coord_out(1,1)=-1;     
    coord_out(1,2)=-1;
    coord_out(1,3)=-1;
end;
    
fprintf('done \n');
fprintf('processed particles: %d \n',i);
fprintf('aligned particles: %d \n',number);

