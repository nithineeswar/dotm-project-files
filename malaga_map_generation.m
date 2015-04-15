clc;
clear all;
close all;

fid = fopen('E:\Datasets\Malaga_Parking_6L\MALAGA.odom', 'rb');
odom = fread(fid, [3072 3], 'float');
fclose(fid);

figure, plot(odom(:, 1), odom(:, 2), 'r.')
hold on;
plot(odom(:, 1), odom(:, 2), 'k')

l = load('E:\Datasets\Malaga_Parking_6L\malaga_selected_localization_log_39999.txt');
n = load('E:\Datasets\Malaga_Parking_6L\malaga_selected_topological_nodes_pose_39999.txt');

l_n = size(n);

p = l([493 : 647 1322:1327 1750:1918 1953:1960 2316:2328 2397:2410], [1 2]);

plot(p(:, 1), p(:, 2), 'y.')
l_p = size(p);

for i = 1:l_n(1,1) 
    x = circle([n(i, 1) n(i, 2)]', 2.8);
    x = [x x(:, 1)];
    hold on;
    plot(x(1, :), x(2, :), 'g');
end

for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.07);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.06);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.05);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.04);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(1, 1) p(2, 2)]', 0.03);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.02);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.01);
    hold on;
    plot(x(1, :), x(2, :), 'y.');
end

for i = 1:l_n(1,1) 
    x = circle([n(i, 1) n(i, 2)]', 2.8);
    hold on;
    plot(x(1, :), x(2, :), 'b:');
end

