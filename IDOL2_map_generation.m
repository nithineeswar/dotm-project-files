clc;
clear all;
close all;

fid = fopen('E:\Datasets\IDOL2\IDOL2_dummy_sunny_1.odom', 'rb');
odom = fread(fid, [894 3], 'float');
fclose(fid);

plot(odom(:, 2), odom(:, 1), 'r.')
hold on;
plot(odom(:, 2), odom(:, 1), 'k')

l = load('E:\Datasets\IDOL2\Results\IDOL2_DB_1_topo_localization_log_DB_1.txt');
n = load('E:\Datasets\IDOL2\Results\IDOL2_DB_1_topological_nodes_pose.txt');

l_n = size(n);

p = l([359 410 507:509 556:562 858:894], [1 2]);

plot(p(:, 2), p(:, 1), 'y.')
l_p = size(p);

for i = 1:l_n(1,1) 
    x = circle([n(i, 1) n(i, 2)]', 0.3);
    x = [x x(:, 1)];
    hold on;
    plot(x(2, :), x(1, :), 'g');
end

for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.07);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.06);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.05);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.04);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.03);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.02);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end
for i = 1:l_p(1,1) 
    x = circle([p(i, 1) p(i, 2)]', 0.01);
    hold on;
    plot(x(2, :), x(1, :), 'y.');
end

for i = 1:l_n(1,1) 
    x = circle([n(i, 1) n(i, 2)]', 0.3);
    hold on;
    plot(x(2, :), x(1, :), 'b:');
end

