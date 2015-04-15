function [data] = rgb2opponent(img)

    img = double(double(img)/double(255));

    r = img(:,:,1);
    g = img(:,:,2);
    b = img(:,:,3);

    data(:, :, 1) = (r + g + b)/5.95;
    data(:, :, 2) = (r - g) + 0.2;
    data(:, :, 3) = (((r + g) - 2*b) + 2)/4;
end

