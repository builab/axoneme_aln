function [new_MarkerPoint,new_avg,num_not_align_part]=tom_refine_avg(in_avg,MarkerPoint,fine_align_parameter,handles)
%
% alignes all particles angain to a given average(mask)  
%
%   INPUT:  in_avg: mask the particles should be aliged to
%           MarkerPoint: structure containing the coordinates,angels and refinement behaviour of the particles  
%           fine_align_parameters: parameters used for the 2d alignment
%           handles: handle containing the list of files, and the path
%             
%   OUTPUT: new_MarkerPoin: updated MarkerPoint structure
%           new_avg: the new average calculated by aligning the particles 
%           num_not_align_part: number of not alignable paticles.
%           
% 
%
%   FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom


fprintf('Refine');
%ini
particle_rad=fine_align_parameter(1);
iterations=fine_align_parameter(2);
thres= [fine_align_parameter(3) fine_align_parameter(4) fine_align_parameter(5) fine_align_parameter(6)];  
particle_mask=in_avg;
avg=zeros(size(in_avg));
num_part=0;
num_not_align_part=0;

for i=1:size(MarkerPoint,2) %hike through all pictures
    
    new_MarkerPoint(i).Filename=handles.List{i};
    
    if (size(MarkerPoint(i).X)>0)
        
        % Magic Hack for Filename
        myfile=[handles.Path '\' handles.List{i}];
        pic=tom_emread(myfile);
        pic=pic.Value;
        
        for k=1:size(MarkerPoint(i).X,2) %walk over all particles
            fprintf('.');
            %check if its poosible to box out the particle
            if ( ((MarkerPoint(i).X(k)-particle_rad*2) > 1) & ((MarkerPoint(i).X(k)+particle_rad*2-1) < size(pic,1)) ...
                    & ((MarkerPoint(i).Y(k)-particle_rad*2) > 1) & ((MarkerPoint(i).Y(k)+particle_rad*2-1) < size(pic,1)) ) 
                
                %box out the particle
                in_region=pic((MarkerPoint(i).X(k)-particle_rad*2+1):(MarkerPoint(i).X(k)+particle_rad*2),(MarkerPoint(i).Y(k)-particle_rad*2+1):(MarkerPoint(i).Y(k)+particle_rad*2));
                s2=size(in_region,1)./2;
                
                % rotate to angle of ref and norm particle to phase contrast  
                rotated_region=imrotate(in_region,-MarkerPoint(i).Angle(k),'bilinear','crop');
                rotated_region_boxed=rotated_region((s2-particle_rad+1):(s2+particle_rad),(s2-particle_rad+1):(s2+particle_rad));
                rotated_region_boxed_norm=(rotated_region_boxed-mean2(rotated_region_boxed))./mean2(rotated_region_boxed);
                
                
                %sbtract particle from mask tom avoid autokorrelation
                in_particle=in_region((s2-particle_rad+1):(s2+particle_rad),(s2-particle_rad+1):(s2+particle_rad));
                
                % assume phase contrast and normalize
                in_particle=(in_particle-mean2(in_particle))./mean2(in_particle);                
                particle_mask_subs=particle_mask-rotated_region_boxed_norm;
                
                %make a 2d alignmet
                [trans,rot,delta,moved_part]=tom_align2d(in_region,particle_mask_subs,particle_rad*2,thres(4),iterations);
                
                % move the particle a little in some directions and try to align it again 
                for mm=1:round(particle_rad)
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[mm mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[-mm -mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[-mm mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[mm -mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[0 mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[0 -mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[0 -mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                    if (  (( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)))==0 )
                        in_region_move=tom_move(in_region ,[0 mm]);  
                        [trans,rot,delta,moved_part]=tom_align2d(in_region_move,particle_mask_subs,particle_rad*2,thres(4),iterations);    
                    end;
                  end; % end of moving  
                
                
                if (  ( abs(delta(1))< thres(1)) & (abs(delta(2)) < thres(2)) & (abs(delta(3)) < thres(3)) )
                    % assume phase contrast and normalize
                    moved_part_norm=(moved_part-mean2(moved_part))./mean2(moved_part);                     
                    %calculate avg
                    avg=avg+moved_part_norm;
                    % save coordinates
                    new_MarkerPoint(i).X(k)=MarkerPoint(i).X(k);     
                    new_MarkerPoint(i).Y(k)=MarkerPoint(i).Y(k);
                    new_MarkerPoint(i).Angle(k)=MarkerPoint(i).Angle(k);
                    new_MarkerPoint(i).Pre_Angle(k)=rot;
                    new_MarkerPoint(i).refine_success(k)=1;
                    new_MarkerPoint(i).CalcX(k)=trans(1);     
                    new_MarkerPoint(i).CalcY(k)=trans(2);
                    new_MarkerPoint(i).CalcAngle(k)=rot;    
                    num_part=num_part+1;
                else
                    disp('alignment failed');
                    %rotate particle to suiteable angle
                    in_particle_rotated=imrotate(in_particle,-MarkerPoint(i).Angle(k),'bilinear','crop');
                    %calculate avg
                    avg=avg+in_particle_rotated;
                    % save coordinates
                    new_MarkerPoint(i).X(k)=MarkerPoint(i).X(k);     
                    new_MarkerPoint(i).Y(k)=MarkerPoint(i).Y(k);
                    new_MarkerPoint(i).CalcX(k)=trans(1);     
                    new_MarkerPoint(i).CalcY(k)=trans(2);
                    new_MarkerPoint(i).CalcAngle(k)=rot;    
                    new_MarkerPoint(i).Angle(k)=MarkerPoint(i).Angle(k);    
                     new_MarkerPoint(i).Pre_Angle(k)=rot;
                    new_MarkerPoint(i).refine_success(k)=0;
                    num_part=num_part+1;
                    num_not_align_part=num_not_align_part+1;
                end;
            end;    
        end;
    end;      
end;
new_avg=avg;
new_MarkerPoint(1).NumberParticle=num_part;
fprintf('done \n');