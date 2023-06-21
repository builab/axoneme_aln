function [fitted_target, varargout] = reverse_cramos(motif, target, angular_range, extract_corner, transform)
% REVERSE_CRAMOS reverse the work done by CRAMOS
%	[fitted_target] = reverse_cramos(motif, target, angular_range, extract_corner, transform)
%	[fitted_target, rev_tfm] = reverse_cramos(motif, target, angular_range, extract_corner, transform)
% PARAMETERS
%	angular_range [phi_start phi_end phi_increment;
%               theta_start theta_end theta_increment;
%               psi_start psi_end psi_increment ]
%  corner      [x_extract y_extract z_extract]
%  motif       3d volume
%  target      3d volume
%  transform   [phi theta psi dx dy dz]
%  fitted_target 3d volume
%  rev_tfm reverse transform
% 
% REFERENCE
% (1) Based on orient_motif.soc by Wadsworth
% @author HB
% @date 29/08/2007

phi_start = angular_range(1,1);
phi_end = angular_range(1,2);
psi_start = angular_range(3,1);
psi_end = angular_range(3,2);


x_extract = extract_corner(1);
y_extract = extract_corner(2);
z_extract = extract_corner(3);

phi = transform(1);
theta = transform(2);
psi = transform(3);
dx = transform(4);
dy = transform(5);
dz = transform(6);

% Size of volume
[target_y, target_x, target_z] = size(target);
[motif_y, motif_x, motif_z] = size(motif);

% New size after calculation
diag = floor(sqrt(motif_x^2 + motif_y^2));
tmp_angle = atan(diag/motif_z);

if max(abs(phi_end), abs(phi_start)) > max(abs(psi_end), abs(psi_start))
    max_angle = max(abs(phi_end), abs(phi_start))*pi/180;
else
    max_angle = max(abs(psi_end), abs(psi_start))*pi/180;
end

padded_x = floor(sin(tmp_angle + max_angle)*sqrt(diag^2 + motif_z^2));
padded_z = floor(cos(tmp_angle - max_angle)*sqrt(diag^2 + motif_z^2));
padded_y = padded_x;
    
% Padded corner
x_corner = floor((padded_x - motif_x)/2) + 1;
y_corner = floor((padded_y - motif_y)/2) + 1;
z_corner = floor((padded_z - motif_z)/2) + 1;

%padded_motif = zeros(padded_y, padded_x, padded_z); % check for accuracy
%padded_motif(y_corner:y_corner+motif_y-1, x_corner:x_corner+motif_x-1, z_corner:z_corner+motif_z-1) = motif;

% Center
padded_center_x = floor(padded_x/2) + 1;
padded_center_y = floor(padded_y/2) + 1;
padded_center_z = floor(padded_z/2) + 1;

target_center_x = floor(target_x/2) + 1;
target_center_y = floor(target_y/2) + 1;
target_center_z = floor(target_z/2) + 1;

% 1nd shift
sh_x1 = target_center_x - dx;
sh_y1 = target_center_y - dy;
sh_z1 = target_center_z - dz;

% 2st rotation
phi_rev = -psi;
theta_rev = -theta;
psi_rev = -phi;

% 2st shift
sh_x2 = x_extract - x_corner - target_center_x + padded_center_x;
sh_y2 = y_extract - y_corner - target_center_y + padded_center_y;
sh_z2 = z_extract - z_corner - target_center_z + padded_center_z;

% Combine
mat = matrix3_from_euler([phi_rev theta_rev psi_rev]);
sh = mat*[sh_x1; sh_y1; sh_z1] + [sh_x2; sh_y2; sh_z2];

% Rotate
target = double(target) - min(min(min(target)));
target = target/max(max(max(target)));
rt_target = tom_rotate(target, [phi_rev psi_rev theta_rev]);
fitted_target = tom_shift(rt_target, sh');

if nargout==2				
	varargout(1) = {[phi_rev theta_rev psi_rev sh']};
end
