function [cltp] = rgb2cltp(img)
    g_img = double(rgb2gray(img));
    img_l = size(g_img);
    ROWS = img_l(1,1);
    COLS = img_l(1,2);
    arr = zeros(1,8);
    cltp = zeros(ROWS, COLS, 4);

    t = 05; % threshold for sign
    c = 16; % threshold for magnitude
    for i = 2:ROWS-1
        for j = 2:COLS-1
            i_c = g_img(i, j); % center pixel inthe active window
            
            % Sign_Upper
            T_patt = g_img(i-1:i+1, j-1:j+1) >= ones(3,3)*(i_c + t);
            arr(1,1:3) = T_patt(1,1:3);
            arr(1, 4) = T_patt(2, 3);
            arr(1, 5:6) = T_patt(3, 3:-1:2);
            arr(1, 7:8) = T_patt(3:-1:2, 1);
            cltp(i, j, 1) = bi2de(arr);

            % Magnitude_Upper
            T_patt = abs(g_img(i-1:i+1, j-1:j+1) - ones(3,3)*(i_c + t)) >= c;
            arr(1,1:3) = T_patt(1,1:3);
            arr(1, 4) = T_patt(2, 3);
            arr(1, 5:6) = T_patt(3, 3:-1:2);
            arr(1, 7:8) = T_patt(3:-1:2, 1);
            cltp(i, j, 2) = bi2de(arr);

            % Sign_Lower
            T_patt = g_img(i-1:i+1, j-1:j+1) < ones(3,3)*(i_c - t);
            arr(1,1:3) = T_patt(1,1:3);
            arr(1, 4) = T_patt(2, 3);
            arr(1, 5:6) = T_patt(3, 3:-1:2);
            arr(1, 7:8) = T_patt(3:-1:2, 1);
            cltp(i, j, 3) = bi2de(arr);
            
            % Magnitude_Lower
            T_patt = abs(g_img(i-1:i+1, j-1:j+1) - ones(3,3)*(i_c - t)) < c;
            arr(1,1:3) = T_patt(1,1:3);
            arr(1, 4) = T_patt(2, 3);
            arr(1, 5:6) = T_patt(3, 3:-1:2);
            arr(1, 7:8) = T_patt(3:-1:2, 1);
            cltp(i, j, 4) = bi2de(arr);            
        end
    end
    cltp = cltp/255;
end

