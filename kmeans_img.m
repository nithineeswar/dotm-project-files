function [k_means, cluster_index, cluster_weight, covariance_matrix] = kmeans_img(initial, feature_block)
    temp = size(initial);
    k_clusters = temp(1,2);
    k_means = initial;
    
    feature_l = size(feature_block);
    cluster_index = zeros(feature_l(1, 1), feature_l(1, 2));
    
    ITR_MAX = 3;
    skip = 2;
    for iteration = 1:ITR_MAX
        if iteration == ITR_MAX
            skip = 1;
        end
        cluster_sum = zeros(feature_l(1, 3), k_clusters);
        cluster_weight = zeros(1, k_clusters);
        feature_vector = zeros(feature_l(1, 3), k_clusters); 
        for i = 1:skip:feature_l(1, 1)
            for j = 1:skip:feature_l(1, 2)
                temp = feature_block(i, j, :);
                for k = 1:k_clusters
                    feature_vector(:, k) = temp(:);
                end
                [m, index] = min(sum(abs(feature_vector - k_means)));
                cluster_index(i, j) = index;
                cluster_sum(:, index) = cluster_sum(:, index) + feature_vector(:,1);
                cluster_weight(1, index) = cluster_weight(1, index) + 1;
            end
        end
        for i = 1:k_clusters
            if cluster_weight(1, i)
                k_means(:,i) = cluster_sum(:,i) ./ cluster_weight(1, i);
            end
        end
    end
    
    covariance_matrix = zeros(feature_l(1, 3), feature_l(1, 3), k_clusters);
    for i = 1:feature_l(1, 1)
        for j = 1:feature_l(1, 2)
            k = 1;
            for k = k:feature_l(1, 3)
                for l = k:feature_l(1, 3)
                       temp = (feature_block(i, j, k) - k_means(k, cluster_index(i, j))) * (feature_block(i, j, l) - k_means(l, cluster_index(i, j)));
                       covariance_matrix(k, l, cluster_index(i, j)) = covariance_matrix(k, l, cluster_index(i, j)) + temp;
                end
            end
        end
    end
    for k = 1:k_clusters
        for i = 2:feature_l(1, 3)
            for j = 1:i
                covariance_matrix(i, j, k) = covariance_matrix(j, i, k);
            end
        end
        if cluster_weight(1, k)
            covariance_matrix(:, :, k) = covariance_matrix(:, :, k) / (cluster_weight(1, k) - 1);
        end
    end    
end