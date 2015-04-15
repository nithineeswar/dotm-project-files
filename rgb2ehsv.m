function [data] = rgb2ehsv(img)
    hsv = rgb2hsv(img);

    h = hsv(:, :, 1);
    h = h * 2*pi;

    cos_h = (cos(h) + 1)/2;
    sin_h = (sin(h) + 1)/2;

    data(:, :, 1) = cos_h;
    data(:, :, 2) = sin_h;
    data(:, :, 3) = hsv(:, :, 2);
    data(:, :, 4) = hsv(:, :, 3);
end

