clc
clear all
close all

fid = fopen('D:\MTech\Navigatioon in a dynamic environment\Kinect\Images\depth\depth_frame_0.dat', 'r');
[depth_frame, count] = fread(fid, inf, '*uint16');
mat = uint16(reshape(depth_frame, [640 480]))';
imshow(mat, [0 6000]);
fclose(fid);

df = bitshift(depth_frame, -8);%im2uint8(depth_frame);
df = df + 1;
m = max(df);
hist = histc(df, 1:m);
pi = hist ./ 307200; 

omega_k = zeros(1,m);
mean_k = zeros(1,m);
    
for k = 1:m
    if k == 1
        omega_k(1, k) = pi(k,1);
        mean_k(1, k) = (double(k - 1) * pi(k,1));
    else
        omega_k(1, k) = omega_k(1, k-1) + pi(k,1);
        mean_k(1, k) = mean_k(1, k-1) + (double(k - 1) * pi(k,1));
    end
end
    
mean_t = mean_k(end);
sigma_b_sqd = ((mean_t .* omega_k) - mean_k).^2 ./ (omega_k .* (1 - omega_k ));
[max_val, threshold] = max(sigma_b_sqd);

threshold = threshold - 1;
bw = ones(307200, 1);
df = df - 1;

if threshold < mean_t
    for i = 1:307200
        if df(i, 1) < threshold
            bw(i,1) = 0;
        end
    end
else
    for i = 1:307200
        if df(i, 1) > threshold
            bw(i,1) = 0;
        end
    end
end

BW = reshape(bw, [640 480])';
gt = uint16(BW .* double(reshape(depth_frame, [640 480])'));
figure, imshow(gt, [0 6000]);