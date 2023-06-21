% Batch align_mtb, adapted for ODA_MW
% USE FOR NOISY MICROTUBULE SEARCH
% INCLUDE FILTERING INTO SCRIPT

target_path = '~/data/work.cab/dev/cluster/data/oda_mw/star';
doc_path = '~/data/work.cab/dev/cluster/data/oda_mw/star';
output_path = '~/data/work.cab/dev/cluster/data/oda_mw/star';
motif_file = '~/data/work.cab/dev/align_mtb/input/motif.spi';
doc_file = 'doc_total_017.spi';
data_name = 'data1_';

% read euler angle from file
unix(['cat ' doc_path '/' doc_file ' | grep ''^[[:space:]]*[0-9]''  > aln.txt']);
euler_all = load('aln.txt');

angular_range = [-3 3 1; -3 3 1; -3 3 1];
extract_corner = [32 20 10];
thresh = -0.1;

% For checking purpose (multicore problem)
phi_loop = length(angular_range(1,1):angular_range(1,3):angular_range(1,2));
theta_loop = length(angular_range(2,1):angular_range(2,3):angular_range(2,2));
psi_loop = length(angular_range(3,1):angular_range(3,3):angular_range(3,2));

%Run align micro
motif_str = tom_spiderread2(motif_file);
motif = motif_str.data;

%Low pass filter
%100,1000,0.02 -> low 2, high 15, smooth factor 2
bnd_filter = [2 15 2];
box = [-6 6 -6 6 -6 6];

% List of file
list = 1:18;
aln_param = zeros(length(list), 6);

for i = list

iter_missing = 0;
stri = sprintf('%0.3d',i);
	
%make target
original_target_file = [data_name stri '.spi'];
im_target_file = [data_name 'im_' stri '.spi'];

disp(original_target_file)

cd(target_path)
unix(['bint -bin 2,2,2 -invert ' original_target_file ' ' im_target_file]);
%unix(['bfilter -bandpass 60,1000,0.002 -sampling 14.4 ' im_target_file ' ' fil_target_file]);

target_str = tom_spiderread2(im_target_file);
target = target_str.data;

euler = euler_all(i,3:5);
tomo_orient = [-95.5 3 0];

mat01 = matrix3_from_euler(tomo_orient);
mat02 = matrix3_from_euler(euler);
mat_cb = mat02*mat01;
euler = euler_from_matrix3(mat_cb);

disp(num2str(euler))
cd ..
tic
peak_list = mc_cramos(motif, target, angular_range, thresh, bnd_filter, euler);

% Safe checking
if size(peak_list, 1) ~= phi_loop*theta_loop*psi_loop
    disp('WARNING Iteration missing in multicore')
    iter_missing  = 1;
end

toc
%
[peak_sort, peak_indx] = sort(peak_list(:,7),'descend');
max_peak = peak_list(peak_indx(1),:);
disp(num2str(max_peak))

% Reverse transform
[fitted_target, rev_tfm] = reverse_cramos(motif, target, angular_range, extract_corner, max_peak);

aln_param(i,7) = max_peak(7);
aln_param(i,1:6) = rev_tfm;
%tom_spiderwrite2([output_path '/aln_' stri '.spi'], fitted_target);

end

aln_param(:,4:6) = aln_param(:,4:6)*2;
write_spider_doc(aln_param, [output_path '/doc_cramos_017.spi']);



