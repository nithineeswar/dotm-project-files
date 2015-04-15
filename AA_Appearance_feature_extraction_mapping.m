clc;
clear all;
close all;

cd E:\Datasets\test_files;
img_name_arr = dir;
length = size(img_name_arr);
start = 3;
nodes = start;
block_size = 80;
THRESHOLD = 150000;

r_block = 3;
c_block = 4;

bit_shift = -4;
b = bitshift(256, bit_shift);
blocks = zeros(block_size, block_size, 3, r_block, c_block);
block_mean = zeros(1,3,r_block, c_block);

tic;
for img_num = start:length(1,1)
    close all;
    img = imread(img_name_arr(img_num, 1).name);

    %------------Local Image statistics
    block_hist = zeros(1000, 4, r_block, c_block);
    block_bin_presence = zeros(4096,1, r_block, c_block);
    block_histogram = zeros(b, b, b, r_block, c_block);
    for i = 0:r_block-1
        for j = 0:c_block-1
            blocks(:,:,:,i+1,j+1) = bitshift(img((i*block_size +1):((i+1)*block_size), ...
                (j*block_size +1):((j+1)*block_size), :), bit_shift);
            block_mean(:,:, i+1, j+1) = uint8(double(sum(sum(blocks(:,:,:,i+1,j+1)))) ./ double(6400));
    %       local statistics  
            for i1 = 1:block_size
                for j1 = 1:block_size 
                    i2 = blocks(i1, j1, 1, i+1, j+1);% + 1;
                    j2 = blocks(i1, j1, 2, i+1, j+1);% + 1;
                    k2 = blocks(i1, j1, 3, i+1, j+1);% + 1;
                    for k = 1: 1000
                         if (block_hist(k, 4, (i+1), (j+1)) == 0)
                            block_hist(k, 1:3, (i+1), (j+1)) = [i2 j2 k2]; 
                            block_hist(k, 4, (i+1), (j+1)) = block_hist(k, 4, (i+1), (j+1)) + 1;
                            block_bin_presence((i2*256 + j2*16 + k2+1), 1, (i+1), (j+1)) = 1;
                            break;
                         else
                            if (i2 == block_hist(k, 1, (i+1), (j+1)) && j2 == block_hist(k, 2, (i+1), (j+1)) && k2 == block_hist(k, 3, (i+1), (j+1)))
                                block_hist(k, 4, (i+1), (j+1)) = block_hist(k, 4, (i+1), (j+1)) + 1;
                                break;
                            end
                         end
                    end
                    i2 = i2+1;
                    j2 = j2+1;
                    k2 = k2+1;
                    block_histogram(i2, j2, k2, i+1, j+1) = block_histogram(i2, j2, k2, i+1, j+1) + 1;
                end
            end
        end
     end

    curnt_img_global_hist = zeros(b, b, b);
    block_mean_pix_num = zeros(r_block, c_block);

    offset = 1;
    round_off = 1 + 2 * offset;

    for i = 1:r_block
        for j=1:c_block
        %       global statistics  
            curnt_img_global_hist = curnt_img_global_hist + block_histogram(:, :, :, i,j);

            i2 = block_mean(1, 1, i, j);
            j2 = block_mean(1, 2, i, j);
            k2 = block_mean(1, 3, i, j);

            if (i2 > 0 && i2 < b-1) || (j2 > 0 && j2 < b-1) || (k2 > 0 && k2 < b-1)
                i_range = (i2:i2 + round_off-1);
                j_range = (j2:j2 + round_off-1);
                k_range = (k2:k2 + round_off-1);
            end

            if (i2 == 0) || (j2 == 0) || (k2 == 0)
                i_range = (1:round_off);
                j_range = (1:round_off);
                k_range = (1:round_off);
            end

            if (i2 > b-round_off) || (j2 > b-round_off) || (k2 > b-round_off)
                i_range = (b - round_off-1:b);
                j_range = (b - round_off-1:b);
                k_range = (b - round_off-1:b);
            end
            block_mean_pix_num(i, j) = sum(sum(sum(block_histogram(i_range, j_range, k_range, i, j))));
        end
    end

    block_connectivity = zeros(r_block, c_block);
    
    for i = 1:r_block
        for j = 1:c_block
            connectivity_score = 0;
            
            if (i-1 > 0)
                if (j-1 > 0)
                    connectivity_score = abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i-1,j-1)));
                end
                connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i-1,j)));
                if j+1 <= c_block
                    connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i-1,j+1)));
                end
            end

            if (j-1 > 0)
                connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i,j-1)));
            end
            if j+1 <= c_block
                connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i,j+1)));
            end

            if i+1 <= r_block
                if mod(j-1, c_block)
                    connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i+1,j-1)));
                end
                connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i+1,j)));
                if j+1 <= c_block
                    connectivity_score = connectivity_score + abs(double(block_mean(:,:, i, j)) - double(block_mean(:,:,i+1,j+1)));
                end
            end
            block_connectivity(i, j) = sum(connectivity_score);
        end
    end

    curnt_img_features = uint16([img_num; block_histogram(:); block_mean(:);...
                    block_mean_pix_num(:); block_connectivity(:)]);
    curnt_img_global_hist = curnt_img_global_hist(:);
    
    curnt_block_bin_presence = block_bin_presence;
    curnt_block_hist = block_hist;

    if img_num == start
        node_img_features = curnt_img_features;
        node_img_global_hist = curnt_img_global_hist;
        node_block_bin_presence = curnt_block_bin_presence;
        node_block_hist = curnt_block_hist;
    else
        count = size(node_img_features);
        dist_measure = zeros(1, count(1,2));
        d11 = 0;
        for i = 1:count(1,2)
            g1 =  sum(abs(double(node_img_global_hist(:,i)) - double(curnt_img_global_hist)));
            d1 = sum(abs(double(node_img_features(2:49153,i)) - double(curnt_img_features(2:49153, 1))));
            d2 = sum(abs(double(node_img_features(49154:49213,i)) - double(curnt_img_features(49154:49213, 1))));
            dist_measure(1,i) = g1 + (d1 + d2);% * 6400;
        end

        if  min(dist_measure) > THRESHOLD
            nodes = [nodes; img_num];
            node_img_features = [node_img_features curnt_img_features];
            node_img_global_hist = [node_img_global_hist curnt_img_global_hist];
        end
   
        if img_num ~= start
            temp = zeros(1, 2);
            [temp(1,1), temp(1,2)] = min(dist_measure);
            [img_num temp]
        else
            [img_num 0]
        end
    end
end
toc;