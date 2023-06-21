% Batch align_mtb, adapted for ODA_MW
organism = 'tetra';
target_path = '/mol/ish/Data/Huy_tmp/aln_demo/input';
doc_path =  '/mol/ish/Data/Huy_tmp/aln_demo/input';
output_path = '/mol/ish/Data/Huy_tmp/aln_demo/output';
motif_file = '/mol/ish/Data/Huy_tmp/aln_demo/motif/motif.spi';
mask_file = '/mol/ish/Data/Huy_tmp/aln_demo/motif/motif_mtb_mask.spi';

angular_range = [-7 7 1; -5 5 1; -7 7 1]; % [Phi_start Phi_end Phi_inc; Theta_start ...]
extract_corner = [32 20 10]; % Extract corner of motif from average file
bnd_filter = [2 15 2]; % [low hi sigma] in pixels

% List of file to run
list = 1:2;


% Read motif & mask
motif_str = tom_spiderread2(motif_file);
motif = motif_str.data;
mask_str = tom_spiderread2(mask_file);
mask = mask_str.data;


for i = list

    stri = sprintf('%0.3d',i);

    % Read target data
    cd(target_path)
    target_file = [organism '_int_' stri '.spi'];
    unix(['bint -bin 2,2,2 -invert ' organism '_rt_' stri '.spi ' target_file]); % Bin & invert contrast
    target_str = tom_spiderread2([target_path '/' target_file]);
    target = target_str.data;
    
    % read euler angle from file
    cd(doc_path)
    doc_file = ['doc_mac_' organism '_' stri '.spi'];
    disp(doc_file)

    fid = fopen(doc_file, 'rt');
    while (1)
        tline = fgetl(fid);
        if findstr(tline, ';')
            continue;
        end
        doc_content = sscanf(tline, '%d %d %f %f %f %f %f %f');
        euler = doc_content(3:5)';
        break;
    end
    fclose(fid);

    % Checking original missing wedge orientation
    if find(0:6 == i)
        tilt_info = [-96.5 -60 60];
    elseif (7:14 == i)
        tilt_info = [-96.5 -60 60];
    else
        tilt_info = [-96.5 -60 60];
    end

    disp(['Euler: ' num2str(euler)])

    % Calculate alignment
    peak_list = cramos_mask(motif, target, angular_range, mask, bnd_filter, tilt_info, euler);

    % Produce reverse transform document
    [peak_sort, peak_indx] = sort(peak_list(:,7),'descend');
    max_peak = peak_list(peak_indx(1),:);
    disp(max_peak)
    [fitted_target, rev_tfm] = reverse_cramos(motif, target, angular_range, extract_corner, max_peak);

    rev_tfm(4:6) = rev_tfm(4:6)*2; % Because of binning, tranlation is double

    disp(['Reverse Transform' num2str(rev_tfm)])
    disp(['Output doc ' output_path '/doc_aln_' organism '_' stri '.spi'])
    write_spider_doc([rev_tfm max_peak(7)], [output_path '/doc_aln_' organism '_' stri '.spi']);

    cd(target_path)
    unix(['rm ' target_file]);
end

exit;
