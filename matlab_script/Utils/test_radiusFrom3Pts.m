% Test file for radiusFrom3Pts function visually
p1 = [10 2 0];
p2 = [13 4 0];
p3 = [17 3 0];

a = [p1; p2 ; p3];

plot(a(:,1), a(:,2), 'b-');

title(num2str(radiusFrom3Pts(p1, p2, p3)));

C = createCircle(p1(1:2), p2(1:2), p3(1:2))
