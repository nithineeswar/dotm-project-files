clc;
clear all;
close all;

% standard Hough Trnsform implementaion for line detection

img = rgb2gray(imread('E:\Datasets\Bannerghatta_test_data\IMG_2128.JPG'));
img_edge = edge(img, 'canny');
imshow(img_edge);
theta = (0:2:180)' * pi / 180;
m = tan(theta);
l_img = size(img_edge);
l_theta = size(theta);

H = zeros(650, l_theta(1,1));
count = 0;

for i = 1:l_img(1,1)
    for j = 1:l_img(1,2)
        if img_edge(i, j)
                count = count+1;            
            for k = 1:l_theta(1,1)
                x = i;
                y = j;
                rho = 241 + x * cos(theta(k,1)) + y * sin(theta(k,1));
                H(uint16(rho), k) = H(uint16(rho), k)+ 1;
            end
        end
    end
end

[sum(sum(H>25)) sum(sum(H>50)) sum(sum(H>100)) sum(sum(H>150)) sum(sum(H>200))]