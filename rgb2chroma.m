function [data] = rgb2chroma(img)

    img = double(img);
    RGB = img(:, :, 1) + img(:, :, 2) + img(:, :, 3);
    
    data(:, :, 1) = img(:, :, 1)./RGB;
    data(:, :, 2) = img(:, :, 2)./RGB;
    data(:, :, 3) = img(:, :, 3)./RGB;
end