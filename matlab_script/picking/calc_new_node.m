%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% another way to calculate arc length & period point
curve = spline(oy, oxz);
pp = ppval(curve, oyi);
len = [0 cumsum(sqrt(sum(diff([pp ; oyi],1,2).^2,1)))];

plot3(ox,oy,oz, 'o'), hold on, plot3(pp(1,:), oyi, pp(2,:),'r-')
axis([0 1390 0 2048 0 400]);
view(10, 80);

% find a start point
len_ang = len*pixel_size;
len_ang_new = len_ang - len_ang(start);

indx = [];
period = 960; % IDA
% Forward loop
for i = 1:floor(len_ang(3000)/period)
	step = i*period;
	upper = find(len_ang_new > step);
    if ~isempty(upper)
        indx = [indx ; upper(1)];
    	disp(upper(1));
    end
end

% Backward loop
for i = 1:floor(abs(len_ang(1))/period)
	step = -i*period;
	lower = find(len_ang_new < step);
    if ~isempty(lower)
        indx = [indx ; lower(1)];
        disp(lower(length(lower)));
    end
end

selected_indx  = indx;
