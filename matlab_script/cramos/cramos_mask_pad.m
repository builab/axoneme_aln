function peak_list = cramos_mask_new(ref, vol, mask, angular_range, tilt_info, euler, box)
% CRAMOS constrained RAMOS use a prefered mask rather than a threshold
% 		peak_list = cramos_mask(ref, vol, mask, angular_range, tilt_info, wedge_euler, box)
% PARAMETERS
%	angular_range [phi_start phi_end phi_increment;
%               theta_start theta_end theta_increment;
%               psi_start psi_end psi_increment ]
%  motif       3d volume
%  target      3d volume
%  mask   mask for motif
%  tilt_info   [tiltaxis neg_tilt pos_tilt] (See missing_wedge_3d)
%  euler       euler angle of the wedge
%  bnd_filter  [low high sigma] low & high in pixels, sigma
%  box         box of x, y, z to limit cross correlation search (optional)
%
% EXAMPLE
%   peaks = cramos(motif, target, [-7 7 1; -5 5 1; -7 7 1],mask, ...
%                    [2 15 2], [30 90 10], [20 30 40 50 20 30]);
% REFERENCE:
%(1) http://pauling.wadsworth.org/spider_doc/spider/docs/techs/misc/sigsearch.html
%(2) B.K. Rath et al. (2003) Journal of Structural Biology 144, 95-103 .
%(3) Alan Roseman (2003) Ultramicroscopy 94, 225-236.
%
% @author HB


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



[ref_y, ref_x, ref_z] = size(ref);

pad = ceil(sqrt(ref_y^2 + ref_x^2 + ref_z^2));

corner_x = floor((pad - ref_x)/2);
corner_y = floor((pad - ref_y)/2);
corner_z = floor((pad - ref_z)/2);

padded_ref = zeros(pad, pad, pad);
padded_ref(corner_y:corner_y + ref_y - 1, corner_x:corner_x + ref_x - 1, corner_z:corner_z + ref_z - 1) = ref;

padded_mask = zeros(pad, pad, pad);
padded_mask(corner_y:corner_y + ref_y - 1, corner_x:corner_x + ref_x - 1, corner_z:corner_z + ref_z - 1) = mask;

padded_vol = zeros(pad, pad, pad);
padded_vol(corner_y:corner_y + ref_y - 1, corner_x:corner_x + ref_x - 1, corner_z:corner_z + ref_z - 1) = vol;

% Create wedge


is_box_limited = 0;
if (nargin > 6)
    is_box_limited = 1;
    box(1:2) = box(1:2) + floor(pad/2); % check
    box(3:4) = box(3:4) + floor(pad/2); % check
    box(5:6) = box(5:6) + floor(pad/2); % check
    if box(1) < 1
        box(1) = 1;
    end
    if box(2) > pad
        box(2) = pad;
    end
    if box(3) < 1
        box(3) = 1;
    end
    if box(4) > pad
        box(4) = pad;
    end
    if box(5) < 1
        box(5) = 1;
    end
    if box(6) > pad
        box(6) = pad;
    end
end

% Result list
peak_list = [];

for phi = phi_start:phi_inc:phi_end

    for theta = theta_start:theta_inc:theta_end

        
        for psi = psi_start:psi_inc:psi_end
			% Rotate mask
			padded_vol_rt = tom_rotate(padded_vol, [phi psi theta]);  
			cbn_euler = euler_from_matrix3(matrix3_from_euler([phi theta psi])*matrix3_from_euler(euler));

			wedge = missing_wedge_3d_arbitrary([pad pad pad], tilt_info(1), tilt_info(2), tilt_info(3), cbn_euler);

			ccf = tom_corr(padded_ref, padded_vol_rt, 'norm', padded_mask, wedge, wedge);			
			%ccf = tom_corr(padded_ref, padded_vol_rt, 'norm', padded_mask);			

            % Peak search
            if (is_box_limited) 
                [co, val] = tom_peak(ccf, box);
            else
                [co, val] = tom_peak(ccf);
            end
            
            % Write to file
            dx = co(2) - ceil(pad/2) - 1;
            dy = co(1) - ceil(pad/2) - 1;
            dz = co(3) - ceil(pad/2) - 1;
			
            peak_list = [peak_list ; [phi theta psi dx dy dz val]];
            disp([phi theta psi dx dy dz val])
        end
    end
end

