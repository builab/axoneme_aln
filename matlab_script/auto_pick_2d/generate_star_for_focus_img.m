% Generate a star file for focus image

dimx = 2048;
dimy = 2048;
radius = 108;


start_x = -60;
origins = [];
count = 1;
while (start_x < dimx-2*radius)
    start_x = start_x + radius*3/2;
    start_y = -60;
	while (start_y < dimy-2*radius)
        start_y = start_y + radius*3/2;
		origins = [origins ; start_x start_y 0];
        count = count + 1;

    end
    
end
disp(count)
write_star_file('/mol/ish/Data/Huy_tmp/2d_micrograph_picking/13.star', origins, 'focus_img.star');

