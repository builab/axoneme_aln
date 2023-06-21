function [rmsd, par] = rms(p, q)
% RMS ROOT MEAN SQUARE
%   [rmsd, a] = rms(p, q)
%   a = minimization parameter

pq = sum(sum(sum(p.*q)));
p2 = sum(sum(sum(p.^2)));
q2 = sum(sum(sum(q.^2)));

[m n p] = size(p);

num = m*n*p;

A = q2^2 - num*q2;
B = -2*q2*pq + num*pq;
C = pq^2 - num*p2;

x1 = (-B + sqrt(B^2 - 4*A*C))/(2*A);
x2 = (-B - sqrt(B^2 - 4*A*C))/(2*A);

rms_1 = sqrt((p2 - 2*x1*pq + 2*x1^2*q2)*num);
rms_2 = sqrt((p2 - 2*x2*pq + 2*x2^2*q2)*num);

if rms_1 < rms_2
    rmsd = rms_1;
    par = x1;
else
    rmsd = rms_2;
    par = x2;
end