function [texture_energy] = rgb2gabor(img)
    window_size = 3;
    block_size = [24 32];
    gray_img = double(rgb2gray(img));
    img_l = size(gray_img);
    o = (window_size-1)/2;

    x = (-o:1:o);
    X = x;
    for i = 1:window_size
        X(i, :) = x;
    end

    y = (o:-1:-o)';
    Y = y;
    for i = 1:window_size
        Y(:, i) = y;
    end
    
%     W = log2(32/4);
    u0 = 2.^[log2(8/4) log2(16/4) log2(32/4)] * sqrt(2);
    theta0 = [30 60 120 150].* pi / 180;
%     theta0 = [0 45 90 135].* pi / 180;
%     theta0 = [60 90 150].* pi / 180;
%     theta0 = [60].* pi / 180;
    temp = size(theta0);
    theta_len = temp(1,2);
    temp = size(u0);
    scale_len = temp(1,2);
    filter_len = (theta_len*scale_len);

    gb = zeros(window_size,window_size,(filter_len));
    X0 = 0;
    Y0 = 0;
    for i = 1:theta_len
        for j = 1:scale_len
            s = 0.5 * block_size(1,2)/ u0(1, j);
            s_x = s;
            s_y = 0.3 * s;
%             [u0(1, j) theta0(1,i)]
            X_prime = X .* cos(theta0(1,i)) + Y .* sin(theta0(1,i));
            Y_prime = -X .* cos(theta0(1,i)) + Y .* sin(theta0(1,i));
            % As given in [Jain and Ratha, 1997] equation (1)
            % SeenPauwel et al., 2012 for a different implementation of local feature extraction using gabor filters 
            H = exp( -0.5 * ((X_prime - X0).^2./s_x^2 + (Y_prime-Y0).^2./s_y^2) ) .* cos(2*pi*u0(1,j).* (X_prime-X0) + pi);
            gb(:, :, (i-1)*scale_len + j) = flipdim(flipdim(H, 1), 2);
        end
    end

    filtered = zeros(img_l(1,1), img_l(1,2), filter_len);
    
    for f = 1:filter_len
        temp = conv2(gray_img, gb(:, :, f), 'same');
        filtered(: ,:, f) = temp / sum(sum(gb(:, :, f)));
    end
    
    nl_feature = zeros(img_l(1,1), img_l(1,2), filter_len);
    texture_energy = nl_feature;
    a = 25 * 10^-3;
%     filter = [1 2 1; 2 4 2; 1 2 1];
    filter = ones(3,3);
    for f = 1:filter_len
        temp = exp(-2.*a.*(filtered(:, :, f)));
        nl_feature(:, :, f) = 1- (1+temp).^-1;
%         nl_feature(:, :, f) = (((1-temp) ./(1+temp)) + 1) / 2;
        temp = conv2(nl_feature(:, :, f), filter, 'same');
        texture_energy(:, :, f) = temp;
    end
    texture_energy = texture_energy / sum(sum(filter));
end