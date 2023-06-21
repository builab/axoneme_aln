function angle = angle_set_negpi_to_pi(neg_angle)
% ANGLE_SET_NEGPI_TO_PI

M_PI = 3.14159265358979323846264338327950288;

angle = mod(neg_angle, 2*M_PI);

while ( angle <= -M_PI ) 
    angle = angle + 2*M_PI;
end

while ( angle >   M_PI )
    angle = angle - 2*M_PI;
end
