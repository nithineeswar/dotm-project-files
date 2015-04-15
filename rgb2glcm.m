function [data] = rgb2glcm(img)
    g_img = double(rgb2gray(img));
    
    img_l = size(g_img);    
    data = zeros(img_l(1,1), img_l(1,2), 7);
    
    filter_n = [0 0 0; 0 0 0; 0 1 0];
    filter_e = [0 0 0; 1 0 0; 0 0 0];
    filter_se = [0 0 1; 0 0 0; 0 0 0];
    filter_sw = [1 0 0; 0 0 0; 0 0 0];
    
    cm_n = conv2(g_img, filter_n, 'same');
    cm_e = conv2(g_img, filter_e, 'same');  
    cm_se = conv2(g_img, filter_se, 'same');
    cm_sw = conv2(g_img, filter_sw, 'same');  

    data(:, :, 1) = g_img;
    data(:, :, 7) = floor((cm_n + cm_e + cm_se + cm_sw) / 4);
    
    window = 9;
    window_half = floor(window/2);
    k_diff = zeros(16, 16);
    for i = 0 :15
        k_diff(i+1, :) = abs(-i:15-i);
    end
   i1 = (1:16)' * ones(1, 16);
   j1 = ones(16, 1) * (1:16);    
    tic;
    for i = 1:img_l(1,1)
        for j = 1:img_l(1,2)
            if i >= 5 && i <= img_l(1,1)-4
                range_i = i-window_half:i+window_half;
            else
                if i < 5
                    range_i = 1:window;
                else
                    if i >= img_l(1,1)-4
                        range_i = (img_l(1,1) - (window-1)) : img_l(1,1);
                    end
                end
            end
            if j >= 5 && j <= img_l(1,2)-4
                range_j = j-window_half:j+window_half;
            else
                if i < 5
                    range_j = 1:window;
                else
                    if j >= img_l(1,2)-4
                        range_j = (img_l(1,2) - (window-1)) : img_l(1,2);
                    end
                end
            end            
            roi_1 = bitshift(data(range_i, range_j, 1), -4);
            roi_2 = bitshift(data(range_i, range_j, 7), -4);
            
            cm = zeros(16, 16);
            
            for r = 1:9
                for c = 1:9
                    i1 = roi_1(r, c)+1;
                    i2 = roi_2(r, c)+1;
                    cm(i1, i2) = cm(i1, i2) + 1;
                end
            end
          
           data(i, j, 2) = sum(sum(cm .^2));
           
           contrast = 0;
           for index = 0:15
               contrast = contrast + index^2 * sum(sum(cm .* (k_diff == index*ones(16, 16)))); 
           end
           data(i, j, 3) = contrast;
           
           mean_i = mean(cm, 2) * ones(1, 16);
           mean_j = ones(16, 1) * mean(cm, 1);
           
           var_i = var(cm, ones(16, 1), 2) * ones(1, 16);
           var_j = ones(16, 1) * var(cm, ones(16, 1), 1);     
           
           data(i, j, 4) = sum(sum((i1 - mean_i).*(j1 - mean_j).*cm./(1+var_i.*var_j)));
           
           data(i, j, 5) = sum(sum(cm.*log2(cm+1))); % Homogeneity / Entropy
           data(i, j, 6) = sum(sum(cm ./ (1 + k_diff.^2))); % Local Homogeneity
        end
    end
    toc;
    data(:, :, 1) = data(:, :, 1)/255;
    
    data(:, :, 2) = data(:, :, 2)/10000; % max value case 100^2
    data(:, :, 3) = data(:, :, 3)/2500; % max value case 15^2 * 100, readjusted to 5^2*100 for good scaling
    data(:, :, 4) = data(:, :, 4)/11211; % max value 11211 with uniform sperad of any 100 occurences at (7:16, 7:16)
    data(:, :, 5) = -data(:, :, 5)/664.3856; % max value case 100*log2(100)
    data(:, :, 6) = data(:, :, 6)/100; % max value case 100/(1+0^2)
    data(:, :, 7) = data(:, :, 7)/255; 
end

