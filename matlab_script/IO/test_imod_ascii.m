% Test write_imod_ascii
clear
directives.color = [0 1 0 1];
directives.name = 'Test';
directives.pointsize = 5;
directives.type = 'scattered';

object1.directives = directives;
object1.contour1 = [0 0 1];
object1.contour2 = [1 1 1];

object2.contour1 = [2 2 2];

model.object1 = object1;
model.object2 = object2;

write_imod_ascii(model, 'test.mod');
