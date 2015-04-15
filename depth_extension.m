clc;
clear all;
close all;

I = imread('depth_frame.tiff');

level = graythresh(I);
BW = im2bw(I,level);
ground_truth = uint16(~BW .* double(I));

if any(ground_truth(:, 460:480))
    display('');
else
    ground_truth = uint16(BW .* double(I));
end   

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

% figure, imagesc(predicted);