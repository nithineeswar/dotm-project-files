function [ltp] = rgb2ltp(img)
    img_l = size(img);
    ROWS = img_l(1,1);
    COLS = img_l(1,2);
    arr = zeros(1,8);
    ltp = zeros(ROWS, COLS, 2);
    g_img = double(rgb2gray(img));

    for i = 2:ROWS-1
        for j = 2:COLS-1
            c = g_img(i, j);

            diff = g_img(i-1:i+1, j-1:j+1) - ones(3,3)*c;
            T_patt = double(diff > 5) + -1 * double(diff < -5);

            arr(1,1:3) = T_patt(1,1:3);
            arr(1, 4) = T_patt(2, 3);
            arr(1, 5:6) = T_patt(3, 3:-1:2);
            arr(1, 7:8) = T_patt(3:-1:2, 1);

            ltp(i, j, 1) = bi2de(arr == 1);
            ltp(i, j, 2) = bi2de(arr == -1);
            
        end
    end
    ltp = ltp / 255;
end

