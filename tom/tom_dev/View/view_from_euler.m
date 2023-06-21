function view = view_from_euler(psi, theta, phi)
% VIEW_FROM_EULER Convert 3 euler angles to view
% Source: Bsoft
% Date: 12/01/07

view.x = cos(phi)*sin(theta);
view.y = sin(phi)*sin(theta);
view.z = cos(theta);
view.a = angle_set_negPi_to_Pi(psi + phi);
