function [data] = rgb2edge(img)
    g_img = rgb2gray(img);
    img_l = size(g_img); 
    filter_l = 5;
    data = zeros(img_l(1,1), img_l(1,2), filter_l);
    filtered = data;
    nl_feature = data;
    filter = edge_filter;
    
    filtered(:,:,1) = conv2(double(g_img), double(filter.vertical), 'same');
    filtered(:,:,2) = conv2(double(g_img), double(filter.horizontal), 'same');
    filtered(:,:,3) = conv2(double(g_img), double(filter.directional_45), 'same');
    filtered(:,:,4) = conv2(double(g_img), double(filter.directional_135), 'same');
    filtered(:,:,5) = conv2(double(g_img), double(filter.non_directional), 'same');
    
    a = 25* 10^-3;
    kernel = [1 2 1; 2 4 2; 1 2 1];
    for f = 1:filter_l
        temp = exp(-2.*a.*(filtered(:, :, f)));
        nl_feature(:, :, f) = 1 - (1+temp) .^ -1;
        temp = conv2(nl_feature(:, :, f), kernel, 'same');
        data(:, :, f) = temp/sum(sum(kernel));
    end
end

