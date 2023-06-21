function [MarkerPoint_out]=tom_find_particle_stack(folder,particle_mask,particle_mask_parameters,filter_pic_param,max_ccf_of_angles_param,filter_max_ccf_param,fine_align_parameter,oneormore,bin) 


% this function calls tom_make_particle_mask and tom_find_particle_2d for
% evey picture in given folder
%
%  INPUT:   folder: path of the folder which contains the pictures
%           particle_mask:particle that should be averaged 
%           particle_mask_parameters: parameters used for the building the
%                                     mask with tom_make_particle_mask
%           filter_pic_param: parameters for removing the gradient
%           max_ccf_of_angles_param:parameters for creating the max_ccf function
%           filter_max_ccf_param:parameters for filtering the max_ccf function 
%           fine_align_parameter:parameters needed for 2d alignment
%           oneormore: to know if we search on current image or in the full
%                      directory
%           bin: binning of the image
%  OUTPUT:  MarkerPoint_out
%  
%
%  22/11/03 SN, 24/11/03 tested and bug fixed FB
%
%   Copyright (c) 2004
%   TOM toolbox for Electron Tomography
%   Max-Planck-Institute for Biochemistry
%   Dept. Molecular Structural Biology
%   82152 Martinsried, Germany
%   http://www.biochem.mpg.de/tom



% make a list of files i
if oneormore==-1
    d=dir(folder);
    dd=struct2cell(d);
    file=dd(1,3:size(dd,2));
else
    file=cellstr(oneormore);
end


%figure; tom_imagesc(particle_mask); set(gcf,'Name','start avg'); drawnow;
if bin==0
    avg=particle_mask;
else
    avg=tom_bin(particle_mask,bin);
end
%avg=particle_mask;

num_of_part=0;
%switch oneormore
%    case 'true'
%        file=file(1);
%    case 'false'
%end
for i=1:size(file,2)
    
    path_and_name=strcat(folder,file{i});
    
    if (tom_isemfile(path_and_name)==1 )
        pic=tom_emread(path_and_name);
        if bin==0
            pic=pic.Value;
        else
            pic=tom_bin(pic.Value,bin);
            particle_mask=tom_bin(particle_mask,bin);
        end
        
        %DebugPrint
        fprintf('\nProcessing File: %s \n',path_and_name);
        
        %filter the picture kill middle Value and remove Gradient
        ii=tom_bandpass(pic,0,(size(pic,1)/filter_pic_param));
        pic=tom_bandpass(pic,1,round((size(pic,1)/2)));
        pic=pic-ii;
        
        % create Mask is called for every picture to deal with changeing
        % picture formates
        mask=tom_make_particle_mask(particle_mask,size(pic,1),particle_mask_parameters);
        [coord_out avg]=tom_find_particle_2d(pic,mask,particle_mask,avg,max_ccf_of_angles_param,filter_max_ccf_param,fine_align_parameter);
        if (coord_out(1,1) ~=-1);
            %figure; tom_imagesc(avg); set(gcf,'Name','new avg');
            %particle_mask=avg;
            % Write into MarkerPoint Structrure
            MarkerPoint(i).Filename=file{i};%MarkerPoint(i).Filename=path_and_name;
            MarkerPoint(i).avg=avg;
            for k=1:size(coord_out,1)
                if bin==0
                    MarkerPoint(i).X(k)=coord_out(k,1);
                    MarkerPoint(i).Y(k)=coord_out(k,2);
                else
                    MarkerPoint(i).X(k)=(coord_out(k,1)*2*bin)-2*bin;
                    MarkerPoint(i).Y(k)=(coord_out(k,2)*2*bin)-2*bin;
                end
                MarkerPoint(i).Angle(k)=coord_out(k,3);
                MarkerPoint(i).refine_success(k)=1;
                num_of_part=num_of_part+1;                   
            end

            % Save avg after every image
            %avg_pic_name=strcat('avg_up_to_',file{i});
            %tom_emwrite(avg_pic_name,avg);
        end;    
    end;
end;
MarkerPoint(1).ref=double(avg);
MarkerPoint(1).NumberParticle=num_of_part;
MarkerPoint_out=MarkerPoint;
%msgbox('Power Search done');
%save MarkerPoint;
%tom_emwrite('final_avg',avg);











