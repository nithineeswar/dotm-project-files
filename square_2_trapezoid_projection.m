clc;
clear all;
close all;

I = imread('depth_frame.tiff');

level = graythresh(I);
BW = im2bw(I,level);
ground_truth = uint16(~BW .* double(I));

if any(ground_truth(:, 460:480))
    ;
else
    ground_truth = uint16(BW .* double(I));
end   

% Extracting middle column after otsu segmentation
m = double(ground_truth(:, 321));

for x1 = 1:length(m)
    if m(x1,1)
        break;
    end
end

for x3 = length(m):-1:(x1)
    if m(x3,1)
        break;
    end
end

x2 = floor((x1+x3) / 2 + 0.5);

y1 = m(x1);
y2 = m(x2);
y3 = m(x3);

eq1 = [x1 1 -y1];
eq2 = [x2 1 -y2];
eq3 = [x3 1 -y3];

d1 = y1 + x1*y1;
d2 = y2 + x2*y2;
d3 = y3 + x3*y3;

ls = [eq1; eq2; eq3];
d = [d1; d2; d3];

f1 = (ls'*ls)^-1 * (ls'*d); 
x = double(1:480)';

A1 = f1(1,1);
B1 = f1(2,1);
C1 = f1(3,1);
y_ra = double((A1 .* x + B1) ./ (x + C1));

xt = double(x1:x3)';
n = length(xt);
yt = double(m((x1:x3)) + 1);

% f2--------------------------------------------------------
d2 = (n * sum(xt.^2) - sum(xt)^2);
b2 = (n * sum(xt .* log(yt)) - sum(xt) * sum(log(yt)))/d2;
a2 = (sum(log(yt)) * sum(xt.^2) - sum(xt) * sum(xt .* log(yt)))/d2;

A2 = exp(a2);
B2 = b2;

y_ex = double(A2 .* exp(B2 .* x));

% f3--------------------------------------------------------
b3 = ((n * sum(log(xt) .* log(yt))) - (sum(log(xt)) * sum(log(yt))))...
    /((n * sum(log(xt).^2)) - (sum(log(xt)))^2);
a3 = (sum(log(yt)) - (b3 * sum(log(xt)))) / n;

A3 = exp(a3);
B3 = b3;

y_po = double(A3 .* (x .^ B3));

yra = (A1 .* xt + B1) ./ (xt + C1);
yex = A2 .* exp(B2 .* xt);
ypo = A3 .* (xt.^B3);

model_x = [y_ra y_ex y_po];
model_xt = [yra yex ypo];
[m, dI] = min(sum(abs(double(model_xt) - double([yt yt yt])))); 


predicted = zeros(480, 640);
for i = 1:640
        predicted(:, i) = uint16(model_x(:, dI));
end


%------------------------------Metric Mapping-------------------------------
fid = fopen('C:\Users\nithine\Documents\MATLAB\Kmeans\Training pics\set 2\N1\N1_1rgb_frame.bin', 'rb');
[img, count] = fread(fid, inf, '*uint8');
fclose(fid);

temp = reshape(img, [480*640 3]);
r = reshape(temp(:,1), [640 480])';
g = reshape(temp(:,2), [640 480])';
b = reshape(temp(:,3), [640 480])';
img = reshape([r g b], [480 640 3]);

navigable = zeros(480, 640, 3);
navigable(:,:,2) = 255;
navigable(:,:,3) = 255;

img = (img == navigable);
%flip the image first
img = flipdim(flipdim(img, 1), 2);          

% metric grid with resolution 0.02m
metric_grid = zeros(50, 100);
% Focal point
f = [0 0.0029 0.5];

tic;
for i =1:1:480
    if uint64(model_x(481 - i, dI)) < 2000
        for j = 1:1:640
            if img(i, j)
                t = 0;
                for k =0:1
                    for l = 0:1
                        r = i + k;
                        c = j + l;

                        x = (c - 320) * 5.6 * 10^-6;
                        y = 0;
                        z = 0.5 + (240 - r) * 5.6 * 10^-6;
                        
                        temp_distance = model_x(481-r, dI)*10^-3;

                        t1 = sqrt(temp_distance^2/((f(1,1) - x)^2 + (f(1,2) - y)^2 + (f(1,3) - z)^2));

                        pj_x = x + t1 * (f(1,1) - x);
                        pj_y = y + t1 * (f(1,2) - y);
                        pj_z = z + t1 * (f(1,3) - z);

                        m_x = ceil(abs(50 + pj_x / 0.02));
                        m_y = ceil(abs(pj_y / 0.02  - 40));
                        
                        if m_x < 101 && m_y < 51
                            metric_grid(m_y, m_x) = 1;
                        end
                    end
                end
            end
        end
    else
        break;
    end
end
toc;
imshow(metric_grid)

crnt_navigable_belief = ones(50, 100) * (1 / 5000);
p_emp = sum(sum(((metric_grid == 0) .* 0.2 + (metric_grid == 1) .* 0.8) .* crnt_navigable_belief));
crnt_navigable_belief = (((metric_grid == 0) .* 0.2 + (metric_grid == 1) .* 0.8) .* crnt_navigable_belief) ./ p_emp;
figure, imagesc(crnt_navigable_belief)