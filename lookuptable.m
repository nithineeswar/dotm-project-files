classdef lookuptable
    properties
        current_models;
        max_models;
        feature_l;
        mean;
        weight;
        cova;
    end
    methods
        function obj = lookuptable(max_size, feature_l)
            obj.current_models = 0;
            obj.max_models = max_size;
            obj.feature_l =feature_l;
            obj.mean = zeros(feature_l, max_size);
            obj.weight = zeros(1, max_size);            
            obj.cova = zeros(feature_l, feature_l, max_size);
        end
        
        function obj = update(obj, kmeans, cova, cluster_sum)
            [W, i] = max(cluster_sum);
            %---------- LUT initialization
            if obj.current_models == 0
                while(obj.current_models < obj.max_models && W > 0)
                    if W > 50
                        obj.current_models = obj.current_models + 1;
                        index = obj.current_models;
                        obj.mean(:, index) = kmeans(:, i); 
                        obj.weight(1, index) =  cluster_sum(1, i);
                        obj.cova(:, :, index) = cova(:,:,i);
                        cluster_sum(1, i) = 0;                      
                        [W, i] = max(cluster_sum);                    
                    else
                        cluster_sum(1, i) = 0;                      
                        [W, i] = max(cluster_sum);
                    end
                end
            end
            while obj.current_models > 0 && obj.current_models < obj.max_models && W > 0
                %-----------------------LUT updation-----------------------
                if W > 50
                    for j = 1:obj.current_models
                        feature_diff = double(obj.mean(:, j)) - double(kmeans(:, i));
                        cova_diff = obj.cova(:,:, j) - cova(:,:,i);
                        equal = (obj.cova(:,:, j) == cova(:,:,i));

                        if sum(sum(equal)) == (obj.feature_l)^2
                            cova_diff = eye(obj.feature_l);
                        end

                        if det(cova_diff) == 0
                            cova_diff_inv = 100 * eye(obj.feature_l);
                        else
                            cova_diff_inv = cova_diff^-1;
                        end

                        criterion = feature_diff' * cova_diff_inv * feature_diff;
                        if abs(criterion) <= 0.5
                            obj.mean(:, j) = (obj.mean(:, j) * obj.weight(1, j) + kmeans(:, i) * cluster_sum(1, i))...
                                ./ (obj.weight(1, j) + cluster_sum(1, i));
                            obj.cova(:, :, j) = (obj.cova(:, :, j) .* obj.weight(1, j) + cova(:, :, i) .* cluster_sum(1, i))...
                                ./ (obj.weight(1, j) + cluster_sum(1, i));
                            obj.weight(1, j) = obj.weight(1, j) + cluster_sum(1, i);
                            cluster_sum(1, i) = 0;
                            [W, i] = max(cluster_sum);
                            break;
                        end
                    end  
                    if W > 50
                        obj.current_models = obj.current_models + 1;
                        index = obj.current_models;
                        obj.mean(:, index) = kmeans(:, i); 
                        obj.weight(1, index) =  cluster_sum(1, i);
                        obj.cova(:, :, index) = cova(:,:,i);
                        cluster_sum(1, i) = 0;                      
                        [W, i] = max(cluster_sum);                    
                    end                    
                else
                    cluster_sum(1, i) = 0;                      
                    [W, i] = max(cluster_sum);
                end                      
            end                

            while(W > 50)
                %-----------------------LUT updation-----------------------
                for j = 1:obj.max_models
                    feature_diff = double(obj.mean(:, j)) - double(kmeans(:, i));
                    cova_diff = obj.cova(:,:, j) - cova(:,:,i);
                    equal = (obj.cova(:,:, j) == cova(:,:,i));
                    
                    if sum(sum(equal)) == (obj.feature_l)^2
                        cova_diff = eye(obj.feature_l);
                    end
                    
                    if det(cova_diff) == 0
                        cova_diff_inv = 100 * eye(obj.feature_l);
                    else
                        cova_diff_inv = cova_diff^-1;
                    end
                    
                    criterion = feature_diff' * cova_diff_inv * feature_diff;
                    if abs(criterion) <= 1
                        obj.mean(:, j) = (obj.mean(:, j) * obj.weight(1, j) + kmeans(:, i) * cluster_sum(1, i))...
                            ./ (obj.weight(1, j) + cluster_sum(1, i));
                        obj.cova(:, :, j) = (obj.cova(:, :, j) .* obj.weight(1, j) + cova(:, :, i) .* cluster_sum(1, i))...
                            ./ (obj.weight(1, j) + cluster_sum(1, i));
                        obj.weight(1, j) = obj.weight(1, j) + cluster_sum(1, i);
                        cluster_sum(1, i) = 0;
                        break;
                    end
                end
                %----------------------------------------------------------

                %---------------------LUT Replacement----------------------       
                if cluster_sum(1, i)
                    [w, index] = min(obj.weight);
                    if cluster_sum(1, i) > w
                        obj.mean(:, index) = kmeans(:, i); 
                        obj.weight(1, index) =  cluster_sum(1, i);
                        obj.cova(:, :, index) = cova(:,:,i);
                        cluster_sum(1, i) = 0;
                    end
                end
                %----------------------------------------------------------
                cluster_sum(1, i) = 0; % DISCARD
                [W, i] = max(cluster_sum); % NEXT ENTRY
            end                        
        end
    end
end