clc;
clear all;
close all;
warning('off', 'MATLAB:nearlySingularMatrix');

ROWS = 240;
COLS = 320;
main_dir = 'E:\Datasets\Experimentation';
% dataset = 'LAGR DS3A';
dataset = 'St Lucia';

cd([main_dir '\' dataset '\' 'images\']);
file_name_arr = dir;
length = size(file_name_arr);

% feature = 'gabor';
texture = 'gabor';
texture_l = 12;
feature_l = 16;

feature = ['color_' texture];
% 
texture_path = [main_dir '\' dataset '\' 'texture' '\' texture '\'];
cd(texture_path);
txr_name_arr = dir;

['|' dataset '|->|' feature '|']

LUT_size = 30;
LUT = lookuptable(LUT_size, feature_l);

data =  zeros(ROWS, COLS, feature_l);
threshold = 10;

cd([main_dir '\' dataset '\' 'images\']);
for file_num = 3:length(1,1)
    display(file_num);
    img = imread(file_name_arr(file_num, 1).name);
    
    data(:, :, 1:4) = rgb2ehsv(img);
    data(:, :, 5:feature_l) = double(get_texture([texture_path txr_name_arr(file_num, 1).name], texture_l));

    roi_feature_block = data((ROWS-78:ROWS-15), (COLS/2-63:COLS/2+64), :);
    roi_min = min(min(roi_feature_block));
    roi_max = max(max(roi_feature_block));
    roi_mean = mean(mean(roi_feature_block));
    
    initial = [roi_min(:) roi_mean(:) roi_max(:)];
    [roi_k_means, roi_cluster_index, roi_cluster_weight, roi_covariance_matrix] = kmeans_img(initial, roi_feature_block);
    LUT = LUT.update(roi_k_means, roi_covariance_matrix, roi_cluster_weight);
    
    [block_size, blocks, r_l, c_l] = get_block_size(0);    
    result_path = [main_dir '\' dataset '\' 'result\' 'pixel' '_based\' 'GMM' '\' feature '\'];    
    
    distance_arr = zeros(1, LUT.current_models);
    navigable = ones(r_l, c_l);
    for r = 1:r_l
        for c = 1:c_l
            for l = 1:LUT.current_models
                if det(LUT.cova(:, :, l))
                    pxl_feature = data(((r-1)*block_size(1,1))+1:(r*block_size(1,1)), ((c-1)*block_size(1,2))+1:(c*block_size(1,2)), :);
                    pxl_feature = pxl_feature(:);
                    distance_arr(1, l) =  (LUT.mean(:, l) - pxl_feature)' * LUT.cova(:, :, l)^-1 * (LUT.mean(:, l) - pxl_feature);
                end
            end    
            distance = abs(min(distance_arr));
            if double(floor(distance)) < double(threshold)
                navigable(r, c) = 1;
            else
                navigable(r, c) = -1;
            end
        end
    end
    filename = file_name_arr(file_num, 1).name;
    fl = size(filename);
    filename(1, (fl(1,2) - 2):fl(1,2)) = 'out';
    path_name = [result_path filename];
    fid = fopen(path_name, 'wb');
    fwrite(fid, navigable(:), 'double');
    fclose(fid);    
    
    [block_size, blocks, r_l, c_l] = get_block_size(1);    
    result_path = [main_dir '\' dataset '\' 'result\' 'block' '_based\' 'GMM' '\' feature '\' blocks '\'];    
    
    distance_arr = zeros(1, LUT.current_models);
    navigable = ones(r_l, c_l);
    for r = 1:r_l
        for c = 1:c_l
            for l = 1:LUT.current_models
                if det(LUT.cova(:, :, l))
                    pxl_feature = mean(mean(data(((r-1)*block_size(1,1))+1:(r*block_size(1,1)), ((c-1)*block_size(1,2))+1:(c*block_size(1,2)), :)));
                    pxl_feature = pxl_feature(:);
                    distance_arr(1, l) =  (LUT.mean(:, l) - pxl_feature)' * LUT.cova(:, :, l)^-1 * (LUT.mean(:, l) - pxl_feature);
                end
            end    
            distance = abs(min(distance_arr));
            if double(floor(distance)) < double(threshold)
                navigable(r, c) = 1;
            else
                navigable(r, c) = -1;
            end
        end
    end
    filename = file_name_arr(file_num, 1).name;
    fl = size(filename);
    filename(1, (fl(1,2) - 2):fl(1,2)) = 'out';
    path_name = [result_path filename];
    fid = fopen(path_name, 'wb');
    fwrite(fid, navigable(:), 'double');
    fclose(fid);
    
    [block_size, blocks, r_l, c_l] = get_block_size(3);    
    result_path = [main_dir '\' dataset '\' 'result\' 'block' '_based\' 'GMM' '\' feature '\' blocks '\'];
    
    distance_arr = zeros(1, LUT.current_models);
    navigable = ones(r_l, c_l);
    for r = 1:r_l
        for c = 1:c_l
            for l = 1:LUT.current_models
                if det(LUT.cova(:, :, l))
                    pxl_feature = mean(mean(data(((r-1)*block_size(1,1))+1:(r*block_size(1,1)), ((c-1)*block_size(1,2))+1:(c*block_size(1,2)), :)));
                    pxl_feature = pxl_feature(:);
                    distance_arr(1, l) =  (LUT.mean(:, l) - pxl_feature)' * LUT.cova(:, :, l)^-1 * (LUT.mean(:, l) - pxl_feature);
                end
            end    
            distance = abs(min(distance_arr));
            if double(floor(distance)) < double(threshold)
                navigable(r, c) = 1;
            else
                navigable(r, c) = -1;
            end
        end
    end
    filename = file_name_arr(file_num, 1).name;
    fl = size(filename);
    filename(1, (fl(1,2) - 2):fl(1,2)) = 'out';
    path_name = [result_path filename];
    fid = fopen(path_name, 'wb');
    fwrite(fid, navigable(:), 'double');
    fclose(fid);       
end

