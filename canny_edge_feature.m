clc;
clear all;
close all;

filename = 'irish-forest-road-smooth';
img = imread(['C:\Users\nithine\Desktop\Dirt road terrain\' filename '.jpg']);

sobel_gx = int16([-1 0 1; -2 0 2; -1 0 1]);
sobel_gy = int16([-1 -2 -1; 0 0 0; -1 -2 -1]);

l_img = size(img);
img = img(3:l_img(1,1)-2, 3:l_img(1,2)-2);


l_img = size(img);
img = [img(:,1) img img(:,l_img(1,2))];
img = [img(1, :); img; img(l_img(1,1), :);];

img = int16(img);
l_img = size(img);
 
for i = 2:l_img(1,1)-1
    for j = 2:l_img(1,2)-1
        gradient_magnitude_x(i-1, j-1) = sum(sum(img(i-1:i+1, j-1:j+1) .* sobel_gx));
        gradient_magnitude_y(i-1, j-1) = sum(sum(img(i-1:i+1, j-1:j+1) .* sobel_gy));
    end
end

gradient_magnitude = sqrt(double(gradient_magnitude_x .^ 2 + gradient_magnitude_y .^2));
% figure, imshow(uint8(gradient_magnitude), uint8([0 max(max(gradient_magnitude))]));

gradient_magnitude_x = double(gradient_magnitude_x);
gradient_magnitude_y = double(gradient_magnitude_y);

l_gradient = size(gradient_magnitude);
for i = 1:l_gradient(1,1)
    for j = 1:l_gradient(1,2)
        if gradient_magnitude_y(i,j) ~=0
            temp = mod(atan((gradient_magnitude_x(i, j)) / (gradient_magnitude_y(i, j))) * 180 / pi, 180);
            if (temp >= 0 && temp <= 22.5) || (temp > 157.5 && temp <= 180)
                gradient_orientation(i, j) = 0;
            end
            if (temp > 22.5 && temp <= 67.5)
                gradient_orientation(i, j) = 45;
            end
            if (temp > 67.5 && temp <= 112.5)
                    gradient_orientation(i, j) = 90;
            end
            if (temp > 112.5 && temp <= 157.5)
                gradient_orientation(i, j) = 135;
            end
        else
            if gradient_magnitude_x(i,j) == 0
                gradient_orientation(i, j) = 0;
            else
                gradient_orientation(i, j) = 90;
            end
        end
    end
end

o = 2;% non-maxima supression 
for i = 1+o:l_gradient(1,1)-o
    for j = 1+o:l_gradient(1,2)-o
        switch uint8(gradient_orientation(i, j))
            case 90                
                [M, I] = max(gradient_magnitude(i, j-o:j+o));
                if I ~= 1 + o
                    gradient_magnitude(i, j) = 0;
                else
                    gradient_magnitude(i, j-1) = 0;
                    gradient_magnitude(i, j+1) = 0;
                    gradient_magnitude(i, j-2) = 0;
                    gradient_magnitude(i, j+2) = 0;
                end                
            case 135
                [M, I] = max([gradient_magnitude(i-2, j+2) gradient_magnitude(i-1, j+1) gradient_magnitude(i, j) gradient_magnitude(i+1, j-1) gradient_magnitude(i+2, j-2)]);
                if I ~= 1 + o
                    gradient_magnitude(i, j) = 0;
                else
                    gradient_magnitude(i-1, j+1) = 0;
                    gradient_magnitude(i+1, j-1) = 0;        
                    gradient_magnitude(i-2, j+2) = 0;                    
                    gradient_magnitude(i+2, j-2) = 0;
                end                  
            case 0
                [M, I] = max(gradient_magnitude(i-o:i+o, j));
                if I ~= 1 + o
                    gradient_magnitude(i, j) = 0;
                else
                    gradient_magnitude(i-1, j) = 0;
                    gradient_magnitude(i+1, j) = 0;
                    gradient_magnitude(i-2, j) = 0;
                    gradient_magnitude(i+2, j) = 0;
                end                
            case 45
                [M, I] = max([gradient_magnitude(i-2, j-2) gradient_magnitude(i-1, j-1) gradient_magnitude(i, j) gradient_magnitude(i+1, j+1) gradient_magnitude(i+2, j+2)]);
                if I ~= 1 + o
                    gradient_magnitude(i, j) = 0;
                else
                    gradient_magnitude(i-1, j-1) = 0;
                    gradient_magnitude(i+1, j+1) = 0;
                    gradient_magnitude(i-2, j-2) = 0;
                    gradient_magnitude(i+2, j+2) = 0;
                end                 
        end
    end
end

figure, imshow(uint8(gradient_magnitude), uint8([0 max(max(gradient_magnitude))]));

threshold_low = 20;
threshold_high = 80;

edge_high = zeros(l_gradient(1,1), l_gradient(1,2));
edge_low = zeros(l_gradient(1,1), l_gradient(1,2));

for i = 1:l_gradient(1,1)
    for j = 1:l_gradient(1,2)
        if gradient_magnitude(i,j) >= threshold_high
            edge_high(i,j) = 1;
        end
        if gradient_magnitude(i,j) > threshold_low && gradient_magnitude(i,j) < threshold_high
            edge_low(i, j) = 1;
        end
    end
end

edge1 = edge_high;
for i = 2:l_gradient(1,1)-1
    for j = 2:l_gradient(1,2)-1
        if edge1(i, j) == 0
            temp = edge1(i-1, j-1) || edge1(i-1, j) || edge1(i-1, j+1) || edge1(i, j-1)...
                || edge1(i, j+1) || edge1(i+1, j-1) || edge1(i+1, j) || edge1(i+1, j+1);
            if temp && edge_low(i, j)
                edge1(i, j) = 1;
            end
        end
    end
end
figure, imshow(edge1)