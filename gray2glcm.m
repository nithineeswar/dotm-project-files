function [data_n, data_e] = gray2glcm(img, block_size)

    sub_l = [block_size block_size];
    img_size = size(img);
    r_l = img_size(1,1) / block_size;
    c_l = img_size(1,2) / block_size;
    
    data_n = zeros(1, 7, r_l, c_l);
    data_e = zeros(1, 7, r_l, c_l);
    
    b = -3;
    
    for r = 1:r_l
        for c = 1:c_l
        sub_img = bitshift(img(((r-1)*block_size)+1:(r*block_size), ((c-1)*block_size)+1:(c*block_size)), b);

        cm_n = zeros(2^(8+b), 2^(8+b));
        cm_e = cm_n;

        for i = 2:sub_l(1,1)-1
            for j = 2:sub_l(1,2)-1
                i1 = sub_img(i, j) + 1;
                i2 = sub_img(i-1, j) + 1;
                cm_n(i1, i2) = cm_n(i1, i2) + 1;

                i2 = sub_img(i, j+1) + 1;
                cm_e(i1, i2) = cm_e(i1, i2) + 1;

            end
        end

        homogeneity_n_E = sum(sum(cm_n .^ 2)) / (2^(8+b)* 2^(8+b)); 
        homogeneity_e_E = sum(sum(cm_e .^ 2)) / (2^(8+b)* 2^(8+b)); 

        cm_n_copy = cm_n + double(cm_n == zeros(2^(8+b), 2^(8+b)));
        cm_e_copy = cm_e + double(cm_e == zeros(2^(8+b), 2^(8+b)));

        entropy_n_H = -sum(sum(log2(cm_n_copy).*cm_n_copy)) / (2^(8+b)* 2^(8+b)); 
        entropy_e_H = -sum(sum(log2(cm_e_copy).*cm_e_copy)) / (2^(8+b)* 2^(8+b)); 

        contrast_n_C = 0;
        contrast_e_C = 0;
        local_homogeneity_n_LH = 0;
        local_homogeneity_e_LH = 0;

        for i = 1:2^(8+b)
            for j = 1:2^(8+b)
                temp = (i - j)^2;
                contrast_n_C = contrast_n_C + (temp * cm_n(i, j));
                contrast_e_C = contrast_e_C + (temp * cm_e(i, j));

                local_homogeneity_n_LH = local_homogeneity_n_LH + (cm_n(i, j)/(1 + temp));
                local_homogeneity_e_LH = local_homogeneity_e_LH + (cm_e(i, j)/(1 + temp));
            end
        end

        contrast_n_C = contrast_n_C / ((2^(8+b) - 1) * 2^(8+b)); 
        contrast_e_C = contrast_e_C / ((2^(8+b) - 1) * 2^(8+b)); 
        local_homogeneity_n_LH = local_homogeneity_n_LH / 256;
        local_homogeneity_e_LH = local_homogeneity_e_LH / 256;

        horizontal_mean_n = sum(cm_n, 2) / (2^(8+b));
        horizontal_variance_n = zeros(2^(8+b), 1);

        horizontal_mean_e = sum(cm_e, 2) / (2^(8+b));
        horizontal_variance_e = zeros(2^(8+b), 1);
        for i = 1:(2^(8+b))
            for j = 1:(2^(8+b))
                horizontal_variance_n(i,1) = horizontal_variance_n(i,1) + (horizontal_mean_n(i, 1) - cm_n(i, j))^2;
                horizontal_variance_e(i,1) = horizontal_variance_e(i,1) + (horizontal_mean_e(i, 1) - cm_e(i, j))^2;
            end
        end

        horizontal_variance_n = horizontal_variance_n / (2^(8+b) - 1);
        horizontal_variance_e = horizontal_variance_e / (2^(8+b) - 1);

        vertical_mean_n = sum(cm_n, 1) / (2^(8+b));
        vertical_mean_e = sum(cm_e, 1) / (2^(8+b));

        vertical_variance_n = zeros(1, 2^(8+b));
        vertical_variance_e = zeros(1, 2^(8+b));
        for i = 1:(2^(8+b))
            for j = 1:(2^(8+b))
                vertical_variance_n(1,i) = vertical_variance_n(1,i) + (vertical_mean_n(1, i) - cm_n(i, j))^2;
                vertical_variance_e(1,i) = vertical_variance_e(1,i) + (vertical_mean_e(1, i) - cm_e(i, j))^2;
            end
        end

        vertical_variance_n = vertical_variance_n / (2^(8+b) - 1);
        vertical_variance_e = vertical_variance_e / (2^(8+b) - 1);

        correlation_Cor_n = 0;
        correlation_Cor_e = 0;
        for i = 1:(2^(8+b))
            for j = 1:(2^(8+b))
                if (horizontal_variance_n(i, 1) * vertical_variance_n(1, j))
                    correlation_Cor_n = correlation_Cor_n + ((horizontal_variance_n(i,1) * vertical_variance_n(1, j))^-1 * ...
                                        (i - horizontal_mean_n(i,1)) * (j - vertical_mean_n(1,j)) * cm_n(i, j));
                    correlation_Cor_e = correlation_Cor_e + ((horizontal_variance_e(i,1) * vertical_variance_e(1, j))^-1 * ...
                                        (i - horizontal_mean_e(i,1)) * (j - vertical_mean_e(1,j)) * cm_e(i, j));
                end
            end
        end
        correlation_Cor_n = correlation_Cor_n / 2^(8+b);
        correlation_Cor_e = correlation_Cor_e / 2^(8+b);

        glcm_mean_n(1,1) = sum(((0:2^(8+b)-1)' .* sum(cm_n, 2))) / sum(sum(cm_n));
        glcm_mean_n(1,2) = sum(((0:2^(8+b)-1) .* sum(cm_n, 1))) / sum(sum(cm_n));  
        glcm_mean_e(1,1) = sum(((0:2^(8+b)-1)' .* sum(cm_e, 2))) / sum(sum(cm_e));
        glcm_mean_e(1,2) = sum(((0:2^(8+b)-1) .* sum(cm_e, 1))) / sum(sum(cm_e));  
        
        data_n(:, :, r, c) = [homogeneity_n_E entropy_n_H contrast_n_C local_homogeneity_n_LH correlation_Cor_n glcm_mean_n];
        data_e(:, :, r, c) = [homogeneity_e_E entropy_e_H contrast_e_C local_homogeneity_e_LH correlation_Cor_e glcm_mean_e];        
        end
    end
end