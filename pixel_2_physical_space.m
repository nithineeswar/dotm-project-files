clc;
clear all;
close all;


x = ones(11, 1) * (-1:0.2:1);
y = -5*ones(11, 11);
z = (31:-0.2:29)' * ones(1, 11);
plot3(x, y, z, 'b.')

grid on

% pixel_distance = 5.6 * 10^-6;
f = [0 15 25];


temp_distance = exp(4.8:0.3/10:5.1)' * (ones(1, 11));


t1 = sqrt(temp_distance.^2./((f(1,1) - x).^2 + (f(1,2) - y).^2 + (f(1,3) - z).^2));

pj_x = x + t1 .* (f(1,1)*ones(11,11) - x);
pj_y = y + t1 .* (f(1,2)*ones(11,11) - y);
pj_z = z + t1 .* (f(1,3)*ones(11,11) - z);

hold on;
plot3(pj_x, pj_y, pj_z, 'k.')
hold on;
plot3(pj_x, pj_y, pj_z, 'go')

for i = 1:11
    for j = 1:11
        p = [x(i,j) y(i,j) z(i,j); pj_x(i, j) pj_y(i, j) pj_z(i, j)];
        hold on;
        plot3(p(:, 1), p(:, 2), p(:, 3), 'm-');
    end
end

% axis([-50 100 -50 150 -5 40])