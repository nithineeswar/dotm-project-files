clc;
clear all;
close all;

cd E:\Datasets\Malaga_Parking_6L\Images_rect\reduced_binary\;

img_name_arr = dir;
length = size(img_name_arr);
result = [0 0];
index = 128;
index2 = uint8(index/2);
velocity = 0;

rotation_window = [100 256];
velocity_window = [100 64];

start = 4;

for img_num = start:length(1,1) 
    close all;
    
    img_num
    fid = fopen(img_name_arr(img_num, 1).name, 'rb');
    [RGB_frame, count] = fread(fid, inf, '*uint8'); 
    fclose(fid);
    RGB = reshape(RGB_frame, [256*192 3]);
    r = RGB(:, 1);
    r = reshape(r, [256 192])';
    r1 = r(:);
    g = RGB(:, 2);
    g = reshape(g, [256 192])';
    g1 = g(:);
    b = RGB(:, 3);
    b = reshape(b, [256 192])';
    b1 = b(:);
    img_crnt = reshape([r1 g1 b1], [192 256 3]);
    
    fid = fopen(img_name_arr(img_num-1, 1).name, 'rb');
    [RGB_frame, count] = fread(fid, inf, '*uint8'); 
    fclose(fid);
    RGB = reshape(RGB_frame, [256*192 3]);
    r = RGB(:, 1);
    r = reshape(r, [256 192])';
    r1 = r(:);
    g = RGB(:, 2);
    g = reshape(g, [256 192])';
    g1 = g(:);
    b = RGB(:, 3);
    b = reshape(b, [256 192])';
    b1 = b(:);
    img_prvs = reshape([r1 g1 b1], [192 256 3]);
    
    if img_num == start
        dim = size(img_crnt);
        
        ROWS = dim(1,1);
        COLUMNS = dim(1,2);  
        
        middle_row = ROWS/2;
        middle_col = COLUMNS/2;
        
        row_rotation_crop_range = ((middle_row - (rotation_window(1,1)/2 - 1)) : (middle_row + rotation_window(1,1)/2)); 
        column_rotation_crop_range = ((middle_col - (rotation_window(1,2)/2 - 1)) : (middle_col + (rotation_window(1,2)/2))); 
        
        row_velocity_crop_range = (ROWS - (velocity_window(1,1) -1) : ROWS);  
        column_velocity_crop_range = ((middle_col - (velocity_window(1,2)/2 -1)) : (middle_col + (velocity_window(1,2)/2)));
        
        rotation_shifts = rotation_window(1,2) * 2;
        velocity_shifts = velocity_window(1,1) * 2;
    end
    
    img_crnt_rotation_crop = rgb2gray(img_crnt(row_rotation_crop_range, column_rotation_crop_range, :));
    img_prvs_rotation_crop = rgb2gray(img_prvs(row_rotation_crop_range, column_rotation_crop_range, :));

    img_crnt_velocity_crop = rgb2gray(img_crnt(row_velocity_crop_range, column_velocity_crop_range, :));
    img_prvs_velocity_crop = rgb2gray(img_prvs(row_velocity_crop_range, column_velocity_crop_range, :));

    a = double(sum(img_prvs_rotation_crop, 1) / rotation_window(1,1));
    b = double(sum(img_crnt_rotation_crop, 1) / rotation_window(1,1));
    
%     Rotation    
%     original paper uses a minimum of 30 overlaps, change this
    shift_sum_rotation = double(1000 * ones(1, rotation_shifts-1));
    for i = 75:(rotation_shifts - 74)
        if i < (rotation_window(1,2)+1)
           shift_sum_rotation(1, i) = double(sum(sum(abs(double(a(:,1:i)) - double(b(:,(rotation_window(1,2) - i + 1):rotation_window(1,2)))), 1))) / double(i) ; 
        else
           shift_sum_rotation(1, i) = double(sum(sum(abs(double(a(:,i-(rotation_window(1,2)-1):rotation_window(1,2))) - double(b(:,1:rotation_shifts - i))), 1))) / double((rotation_shifts - i));
        end
    end


    flag = mod(result(img_num-3, 1), 0);
    
    if abs(flag) <= 3    
        Index1 = 177;
        Index2 = 366;
    end
    
    if flag > 3
        Index1 = 256;
        Index2 = 366;
    end
    
    if abs(flag) < -3
        Index1 = 177;
        Index2 = 256;
    end
    
    [min_interest, I_interest] = min(shift_sum_rotation(Index1:Index2));
    I_interest = I_interest + Index1 - 1;
%     temp = shift_sum(1, I_interest);
    I_interest = rotation_window(1,2) - I_interest;
    angular_shift_interest = 70/320 * I_interest;
    
    result = [result; [angular_shift_interest min_interest]];
    
%     Translation
    a = double(sum(img_prvs_velocity_crop, 2)) / double(index);
    b = double(sum(img_crnt_velocity_crop, 2)) / double(index);

    shift_sum_translation = double(zeros(10, 1));

    for i = 1:10 %only checked for 10 shifts, as more shifts are not plausible, in the result 10 corresponds to places of rotation hence not reliable
        temp = abs(double(a(i:100, 1)) - double(b(1:100-(i-1), 1)));
        shift_sum_translation(i, 1) = double(sum(sum(temp))) / double(i); 
    end

    [m, ind] = min(shift_sum_translation);
    velocity = [velocity; ind];
    
end

v = (abs(result(:,1)) < 1) + (abs(result(:,1)) >= 1) .* 0.65;
angle = pi/180.*cumsum(result(:,1));
points = [v.*cos(angle) v.*sin(angle)];
points = cumsum(points);
figure, plot(points(:,1), points(:,2));