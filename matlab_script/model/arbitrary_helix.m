% Script
% Purpose draw an arbitrary helix between 2 points
% HB 20080717

outputFile = '/mol/ish/Data/Huy_tmp/oda1/model/coilIda_pts.txt';
pts1 = [136 76 101];
pts2 = [136 52 101];


distance = sqrt(sum((pts1 - pts2).^2));
rad = 2;
pitch = 1;

t = 0:pi/50:distance/pitch;
z = pitch*t;
x = rad*sin(t);
y = rad*cos(t);

% Calculate transform
rotZ = rotationOz(atan2(pts2(2) - pts1(2),pts2(1) - pts1(1)));
rotY = rotationOy(acos((pts2(3) - pts1(3))/distance));
%rotX = rotationOx(atan2(pts2(3) - pts1(3), pts2(2) - pts1(2))); % rotx = atans(z/y)
%rotY = rotationOy(asin((pts2(1)-pts1(1))/distance)); % roty = asin(z/length);
trans = translation3d(-pts1(1), -pts1(2), -pts1(3));

%totalXform = composeTransforms3d(trans, rotX, rotY);
totalXform = composeTransforms3d(trans, rotZ, rotY);
invXform = inv(totalXform);

xformPts = zeros(length(z), 3);
for i = 1:length(z)
    xformPts(i,:) = transformPoint3d([x(i) y(i) z(i)], invXform);
end

plot3(xformPts(:,1), xformPts(:,2), xformPts(:,3))
model.coil1 = xformPts;

% Produce another coil
t2 = t - pi;
z2 = pitch*t2;
x2 = rad*sin(t);
y2 = rad*cos(t);

xformPts2 = zeros(length(z2), 3);
for i = 1:length(z2)
    xformPts2(i,:) = transformPoint3d([x2(i) y2(i) z2(i)], invXform);
end
hold on
plot3(xformPts2(:,1), xformPts2(:,2), xformPts2(:,3))

model.coil2 = xformPts2;

write_imod_point(model, outputFile);



