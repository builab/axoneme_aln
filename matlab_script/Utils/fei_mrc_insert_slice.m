% -------------------------------------------------------------------------
% Script: FEI_mrc_insert_slice.m
% @purpose to insert a 32b tif file into the tomo stack
% @date 20100219
% @alg read the 32bits tif file, arithmetic adjust so that the avg is the same
% as the next section in the stack.
% @note The mrc file's intensity is the electron count + an offset. In the
% tiff file, there is no offset
% -------------------------------------------------------------------------
tomo_stack_file = 'wt_66.st';
slice_file = 'wt_66_-56.tif';
slice_position = 3; % start with 1
doAutoScaling = 1;
avg_scale = -32568; % if don't want to use automatic scaling

% DON"T CHANGe FROM THis line
header = 1024;
datatype = 2; % 2 bytes
slice = imread(slice_file);
slice = slice';
slice = fliplr(slice);

% Open stack file
%offset = 1024 + 1024*128; % Calculate header

fid = fopen(tomo_stack_file, 'r+','ieee-le');


nx = fread(fid,[1],'int32');        %integer: 4 bytes
ny = fread(fid,[1],'int32');        %integer: 4 bytes
nz = fread(fid,[1],'int32');        %integer: 4 bytes
mode = fread(fid,[1],'int32');      %integer: 4 bytes

fseek(fid, 92, 'bof');
nbytes = fread(fid, [1], 'int32'); % Number of byte in extended header
offset = header + nbytes;

vect = reshape(slice, nx*ny, 1);
slice_avg =  mean(double(vect));
slice_std =  std(double(vect));

% Reading the average slice before & after for average
if (doAutoScaling)
    if (slice_position > 1)
        slice_prev_offset = offset + (slice_position - 2)*nx*ny*datatype;
        fseek(fid, slice_prev_offset, 'bof');
        vprev = fread(fid, nx*ny, 'int16');
    end
    if (slice_position < nz)
        slice_next_offset = offset + slice_position*nx*ny*datatype;
        fseek(fid, slice_next_offset, 'bof');
        vnext = fread(fid, nx*ny, 'int16');
    end
    %im1 = reshape(vprev, nx, ny);
    %imwrite(vol2double(im1), 'test_prev.png');
    %im2 = reshape(vnext, nx, ny);
    %imwrite(vol2double(im2), 'test_next.png');
    if (slice_position == 1)
        avg_scale = mean(vnext);
    elseif (slice_position == nz)
        avg_scale = mean(vprev);
    else
        avg_scale = (mean(vnext) + mean(vprev))/2;
    end
end
% Rescale the slice data
slice = slice - slice_avg + avg_scale;
slice = round(slice);


% Insert
slice_data_offset = offset + (slice_position - 1)*nx*ny*datatype;
fseek(fid, slice_data_offset, 'bof');
fwrite(fid, slice, 'int16');
fclose(fid);