function peak_list = cramos(motif, target, angular_range, thresh, bnd_filter, tilt_info, euler, box)
% CRAMOS constrained RAMOS
%   peak_list = cramos(motif, target, angular_range, thresh, bnd_filter, tilt_info, euler, box)
%
% PARAMETERS
%	angular_range [phi_start phi_end phi_increment;
%               theta_start theta_end theta_increment;
%               psi_start psi_end psi_increment ]
%  motif       3d volume
%  target      3d volume
%  thresh      threshold for motif
%  tilt_info   [tiltaxis neg_tilt pos_tilt] (See missing_wedge_3d)
%  euler       euler angle of the wedge
%  bnd_filter  [low high sigma] low & high in pixels, sigma
%  box         box of x, y, z to limit cross correlation search (optional)
%
% EXAMPLE
%   peaks = cramos(motif, target, [-7 7 1; -5 5 1; -7 7 1], -.1, ...
%                    [2 15 2], [30 90 10], [20 30 40 50 20 30]);
% REFERENCE:
%(1) http://pauling.wadsworth.org/spider_doc/spider/docs/techs/misc/sigsearch.html
%(2) B.K. Rath et al. (2003) Journal of Structural Biology 144, 95-103 .
%(3) Alan Roseman (2003) Ultramicroscopy 94, 225-236.
%
% @author HB
% @date 06/08/2007
% @lastmod 04/10/2007 added filter functionality for the data;

% To calculate box, padded_x + lower limit

% ----------------------------
% Parameters
% ----------------------------

phi_start = angular_range(1,1);
phi_end = angular_range(1,2);
phi_inc = angular_range(1,3);
theta_start = angular_range(2,1);
theta_end = angular_range(2,2);
theta_inc = angular_range(2,3);
psi_start = angular_range(3,1);
psi_end = angular_range(3,2);
psi_inc = angular_range(3,3);

%assym = 1; % Assymetric mask % Not used yet


% ----------------------------
% Preliminary Computation
% ----------------------------

% Size of volume
[target_y, target_x, target_z] = size(target);
[motif_y, motif_x, motif_z] = size(motif);

% Filter target
target = tom_bandpass(target, bnd_filter(1), bnd_filter(2), bnd_filter(3));

% New size after calculation
diag = floor(sqrt(motif_x^2 + motif_y^2));
tmp_angle = atan(diag/motif_z);

if abs(phi_end) > abs(phi_start)
   max_angle = abs(phi_end)*pi/180;
else
    max_angle = abs(phi_start)*pi/180;
end

padded_x = floor(sin(tmp_angle + max_angle)*sqrt(diag^2 + motif_z^2));
padded_z = floor(cos(tmp_angle - max_angle)*sqrt(diag^2 + motif_z^2));
padded_y = padded_x;
    
% Padded corner
x_corner = floor((padded_x - motif_x)/2) + 1;
y_corner = floor((padded_y - motif_y)/2) + 1;
z_corner = floor((padded_z - motif_z)/2) + 1;

padded_motif = zeros(padded_y, padded_x, padded_z); % check for accuracy
padded_motif(y_corner:y_corner+motif_y-1, x_corner:x_corner+motif_x-1, z_corner:z_corner+motif_z-1) = motif;

% Create mask
mask = zeros(padded_y, padded_x, padded_z);
mask(y_corner:y_corner+motif_y-1, x_corner:x_corner+motif_x-1, z_corner:z_corner+motif_z-1) = motif > thresh;
mask = bwareaopen(mask, 300, 26); 

% Create wedge
wedge = missing_wedge_3d_arbitrary(size(padded_motif), tilt_info(1), tilt_info(2), tilt_info(3), euler);

% Tmp file for speed up
target_sq = target.^2; % square of target

target_sq_ft = fftn(target_sq); % FT of target square

target_ft = fftn(target); % FT of target

% Adjust box
is_box_limited = 0;

if (nargin > 7)
    is_box_limited = 1;
    box(1:2) = box(1:2) + floor(target_x/2) - floor(padded_x/2);
    box(3:4) = box(3:4) + floor(target_y/2) - floor(padded_y/2);
    box(5:6) = box(5:6) + floor(target_z/2) - floor(padded_z/2);
    if box(1) < 1
        box(1) = 1;
    end
    if box(2) > target_x-padded_x+ 1
        box(2) = target_x-padded_x+1;
    end
    if box(3) < 1
        box(3) = 1;
    end
    if box(4) > target_y-padded_y+ 1
        box(4) = target_y-padded_y+1;
    end
    if box(5) < 1
        box(5) = 1;
    end
    if box(6) > target_z-padded_z+1
        box(6) = target_z-padded_z+1;
    end
end


% Result list
peak_list = [];

for phi = phi_start:phi_inc:phi_end
    disp(['phi -> ' num2str(phi)])
    
    for theta = theta_start:theta_inc:theta_end
        disp(['  theta -> ' num2str(theta)])
        
        for psi = psi_start:psi_inc:psi_end
            %disp(['     psi -> ' num2str(psi)])

            % rotate mask
            mask_rt = tom_rotate(mask, [phi psi theta]);
            
            % threshold mask
            mask_rt = mask_rt > .5;
            
            total = sum(sum(sum(mask_rt)));
            
            % Create a blank volume = target volume
            padded_mask = zeros(target_y, target_x, target_z);
            
            % Insert rotated mask inside template
            padded_mask(1:padded_y,1:padded_x,1:padded_z) = mask_rt;
            
            % FT of padded mask
            padded_mask_ft = fftn(padded_mask);
            
            % Multiply of Target with complex conjugate of padded mask &
            % inverse FT, F-1(F*(M)F(T)) CHECK !!!
            tmp_1 = ifftn(target_ft.*conj(padded_mask_ft), 'symmetric');
            tmp_1 = tmp_1.^2/(total^2); % 1/P * F^-1(F*(M)F(T))
            
            tmp_2 = ifftn(target_sq_ft.*conj(padded_mask_ft),'symmetric');
            tmp_2 = tmp_2/total; % 1/P * F^-1(F*(M)F(T^2))
            sigma_mt_sq = tmp_2 - tmp_1; % CHECK
            
            % Threshold
            sigma_mt_sq(sigma_mt_sq <=0) = 10^(-10);
            
            % square root
            sigma_mt = sqrt(sigma_mt_sq);
            
            % Trim out
            sigma_mt_trim = sigma_mt(1:target_y-padded_y+1, 1:target_x-padded_x+1,1:target_z-padded_z+1);
            
            % Rotate motif
            motif_rt = tom_rotate(padded_motif, [phi psi theta]);            

            % CRAMOS code here
            motif_rt = ifftn(fftn(motif_rt).*ifftshift(wedge), 'symmetric');
            
            % masked motif
            motif_rt_mask = motif_rt.*mask_rt;
            
            % normalize motif under mask to avg 0, std 1
            %avg_motif = sum(sum(sum(motif_rt_mask)))/total;
            %std_motif = sqrt((sum(sum(sum(motif_rt_mask.^2))) - sum(sum(sum(motif_rt_mask)))^2/total)/(total-1));
            %motif_rt_norm = (motif_rt_mask - avg_motif).*mask_rt/std_motif;
                        
            % Paste into big blank volume
            template = zeros(target_y, target_x, target_z);
            template(1:padded_y, 1:padded_x, 1:padded_z) = motif_rt_mask;
            template_mask = zeros(target_y, target_x, target_z);
            template_mask(1:padded_y, 1:padded_x, 1:padded_z) = mask_rt;
                      
            % Filter template
            template = tom_bandpass(template, bnd_filter(1), bnd_filter(2), bnd_filter(3));
            
            % Normalize template
            avg_template = sum(sum(sum(template.*template_mask)))/total;
            std_template = sqrt((sum(sum(sum((template.^2).*template_mask))) - sum(sum(sum(template.*template_mask)))^2/total)/(total-1));
            template_norm = (template - avg_template).*template_mask/std_template;

            % ft the template
            template_ft = fftn(template_norm);

            % Setting sth == 0 , CHECK
            template_ft(1,1,1) = 0;
            template_ft(1,2,1) = 0;
            
            % Calculate cross correlation
            ccf = ifftn(target_ft.*conj(template_ft), 'symmetric');
            
            % trimming
            ccf_trim = ccf(1:target_y-padded_y+1, 1:target_x-padded_x+1, 1:target_z-padded_z+1);
            ccf_trim = ccf_trim/total;
            
            % divide result with local std array
            local_cc = ccf_trim./sigma_mt_trim;
            
            % Peak search
            if (is_box_limited) 
                [co, val] = tom_peak(local_cc, box);
            else
                [co, val] = tom_peak(local_cc);
            end
            
            % Write to file
            dx = co(2) + floor(padded_x/2) + 1;
            dy = co(1) + floor(padded_y/2) + 1;
            dz = co(3) + floor(padded_z/2) + 1;
            peak_list = [peak_list ; [phi theta psi dx dy dz val]];
            %disp(['           ' num2str(val)])
        end
    end
end
