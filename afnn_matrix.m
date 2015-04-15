classdef afnn_matrix
    properties
        in_arg;
        hidden_layers;
        hidden_layer_neurons;
        out_arg;
        input;
        hidden = layer;
        output = layer;
        act_func;
    end
    methods
%%%%%---------------------------CONSTRUCTOR---------------------------%%%%%      
        function obj = afnn_matrix(in_arg, hidden_layers, neurons, out_arg)
            obj.in_arg = in_arg;
            obj.hidden_layers = hidden_layers;
            obj.hidden_layer_neurons = neurons;
            obj.out_arg = out_arg;
            obj.input = zeros(in_arg, 1);
            obj.hidden(hidden_layers, 1) = layer; 
            obj.output = layer; 
            
            obj.hidden(1,1).weights = zeros(in_arg+1, neurons);
            obj.hidden(1,1).gain = ones(in_arg+1, neurons);
            obj.hidden(1,1).step_direction = zeros(in_arg+1, neurons);
            obj.hidden(1,1).step_direction_prev = zeros(in_arg+1, neurons);
            obj.hidden(1,1).del_w = zeros(in_arg+1, neurons);
            obj.hidden(1,1).del_w_prev = zeros(in_arg+1, neurons);
            
            if hidden_layers > 1
                for L = 2:hidden_layers
                    obj.hidden(L,1).weights = zeros(neurons+1, neurons);
                    obj.hidden(L,1).gain = ones(neurons+1, neurons);
                    obj.hidden(L,1).step_direction = zeros(neurons+1, neurons);
                    obj.hidden(L,1).step_direction_prev = zeros(neurons+1, neurons);
                    obj.hidden(L,1).del_w = zeros(neurons+1, neurons);
                    obj.hidden(L,1).del_w_prev = zeros(neurons+1, neurons);
                end
            end
            
            obj.output.weights = zeros(neurons+1, out_arg);
            obj.output.gain = ones(neurons+1, out_arg);
            obj.output.step_direction = zeros(neurons+1, out_arg);
            obj.output.step_direction_prev = zeros(neurons+1, out_arg);
            obj.output.del_w = zeros(neurons+1, out_arg);
            obj.output.del_w_prev = zeros(neurons+1, out_arg);
            
            % for the first hidden layer
            const = 1;
            if in_arg == 1
                initial_weights = sqrt(const/(neurons));
%                 initial_weight = [initial_weight; -1];
                initial_weights = [initial_weights; -1];
                obj.hidden(1,1).weights =  initial_weights * ones(1, neurons);
            else
                a = -1 * sqrt(const/(in_arg));
                b = -a;
                bw = b - a;
                initial_weights = (b:-bw/(in_arg-1):a)';  

                for N = 1:neurons
                    index = randperm(size(initial_weights, 1));
                    shuffle_init_weights = initial_weights;
                    for i = 1:size(initial_weights, 1)
                        shuffle_init_weights(i, 1) = initial_weights(index(1, i), 1);
                    end

                    obj.hidden(1, 1).weights(:, N) = [shuffle_init_weights; -1];
                end
            end

            % for rest of the hidden layer
            a = -1 * sqrt(const/(neurons));
            b = -a;
            bw = b - a;
            initial_weights = (b:-bw/(neurons-1):a)';             
            
            if hidden_layers > 1
                for L = 2:hidden_layers
                    for N = 1:neurons
                        index = randperm(size(initial_weights, 1));
                        shuffle_init_weights = initial_weights;
                        for i = 1:size(initial_weights, 1)
                            shuffle_init_weights(i, 1) = initial_weights(index(1, i), 1);
                        end

                        obj.hidden(L, 1).weights(:, N) = [shuffle_init_weights; -1];
                    end
                end
            end
            
            % for the output layer
            a = -1 * sqrt(const/(neurons));
            b = -a;
            bw = b - a;
            initial_weights = (b:-bw/(neurons-1):a)';  
            
            for N = 1:out_arg
                index = randperm(size(initial_weights, 1));
                shuffle_init_weights = initial_weights;
                for i = 1:size(initial_weights, 1)
                    shuffle_init_weights(i, 1) = initial_weights(index(1, i), 1);
                end

                obj.output.weights(:, N) = [shuffle_init_weights; -1];
            end
        end
%%%%%-----------------------------------------------------------------%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

%%%%%---------------------------FORWARD PASS--------------------------%%%%%        
        function obj = forward_pass(obj)
            % for the first hidden layer
            [a,b,obj.hidden(1,1).a_out] = activate(obj.hidden(1,1).weights' * [obj.input; 1], obj.act_func);
            
            % for rest of the hidden layer
            if obj.hidden_layers > 1            
                for L = 2:obj.hidden_layers
                    [a,b,obj.hidden(L,1).a_out] = activate(obj.hidden(L,1).weights' * [obj.hidden(L-1,1).a_out; 1], obj.act_func);
                end
            end
            
            % for output layer
            [a,b,obj.output.a_out] = activate(obj.output.weights' * [obj.hidden(obj.hidden_layers,1).a_out; 1], obj.act_func);
            % >>>>>LINEAR ACTIVATION<<<<<<
%             obj.output.a_out = obj.output.weights' * [obj.hidden(obj.hidden_layers,1).a_out; 1];
        end
%%%%%-----------------------------------------------------------------%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%--------------------------BACK PROPAGATON------------------------%%%%%
        function obj = back_propagate(obj, error)
            % for output layer
            obj.output.local_error = error;
            obj.output.f_prime = activation_prime(obj.output.a_out, obj.act_func);
            obj.output.local_gradient = obj.output.f_prime .* obj.output.local_error;
            
            % for the last hidden layer
            L = obj.hidden_layers;
            rows = (1:obj.hidden_layer_neurons);
            obj.hidden(L, 1).local_error = obj.output.weights(rows, :) * obj.output.local_gradient;
            obj.hidden(L, 1).f_prime = activation_prime(obj.hidden(L, 1).a_out, obj.act_func);
            obj.hidden(L, 1).local_gradient = obj.hidden(L, 1).f_prime .* obj.hidden(L, 1).local_error;
            
            % for the remaining hidden layers
            if obj.hidden_layers > 1
                for L = (obj.hidden_layers-1):-1:1
                    obj.hidden(L, 1).local_error = obj.hidden(L+1,1).weights(rows, :) * obj.hidden(L+1,1).local_gradient;
                    obj.hidden(L, 1).f_prime = activation_prime(obj.hidden(L, 1).a_out, obj.act_func);
                    obj.hidden(L, 1).local_gradient = obj.hidden(L, 1).f_prime .* obj.hidden(L, 1).local_error;
                end            
            end
        end      
%%%%%-----------------------------------------------------------------%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%---------------------------WEIGHT UPDATE-------------------------%%%%%
        function obj = weight_update(obj, eta_0)
            lower = 0.1;
            upper = 100;
            mul_const = 0.75;
%             add_const = 0.001;
            mu = 0.75;
            neurons = obj.hidden_layer_neurons;
            
            % for the first hidden layer
%             synaptic_weights_1 = obj.in_arg * obj.hidden_layer_neurons;

            eta = eta_0/sqrt(obj.in_arg);% * 1/sqrt(synaptic_weights_1);
            add_const = eta/5;
            out_prev_l = [obj.input; 1] * ones(1, obj.hidden_layer_neurons);
            local_gradient = ones(obj.in_arg+1,1) * obj.hidden(1, 1).local_gradient';

            obj.hidden(1,1).del_w_prev = obj.hidden(1, 1).del_w;
            obj.hidden(1,1).step_direction_prev = obj.hidden(1, 1).step_direction;
            obj.hidden(1,1).step_direction = local_gradient .* out_prev_l;
            
%             sign_check = obj.hidden(1, 1).del_w_prev .* obj.hidden(1, 1).del_w;
%             limit_check = (obj.hidden(1, 1).gain <= upper) .* (obj.hidden(1, 1).gain >= lower);
%             additive_correction = (sign_check > 0) .* limit_check * add_const;
%             obj.hidden(1,1).gain = obj.hidden(1, 1).gain + additive_correction;
%             multiplicative_correction = ((sign_check < 0).* limit_check * mul_const) + (sign_check >= 0);
%             obj.hidden(1,1).gain = obj.hidden(1, 1).gain .* multiplicative_correction;
            
            obj.hidden(1,1).del_w = (eta * obj.hidden(1,1).gain) .* obj.hidden(1,1).step_direction;
            obj.hidden(1,1).weights =...
            obj.hidden(1,1).weights + (mu * obj.hidden(1,1).del_w_prev) + obj.hidden(1,1).del_w;            

            % for rest of the hidden layer
%             synaptic_weights = 0;
            if obj.hidden_layers > 1
                for L = 2:obj.hidden_layers
%                     synaptic_weights = synaptic_weights_1 + (L-1)*obj.hidden_layer_neurons^2;

                    eta = eta_0/sqrt(L*obj.hidden_layer_neurons);% * 1/sqrt(synaptic_weights);
                    add_const = eta/5;
                    out_prev_l = [obj.hidden(L-1).a_out; 1] * ones(1, obj.hidden_layer_neurons);
                    local_gradient = ones(neurons+1,1) * obj.hidden(L, 1).local_gradient';                    

                    obj.hidden(L,1).del_w_prev = obj.hidden(L,1).del_w;
                    obj.hidden(L,1).step_direction_prev = obj.hidden(L,1).step_direction;
                    obj.hidden(L,1).step_direction = local_gradient .* out_prev_l;
                    
%                     sign_check = obj.hidden(L,1).del_w_prev .* obj.hidden(L,1).del_w;
%                     limit_check = (obj.hidden(L,1).gain <= upper) .* (obj.hidden(L,1).gain >= lower);
%                     additive_correction = (sign_check > 0) .* limit_check * add_const;
%                     obj.hidden(L,1).gain = obj.hidden(L,1).gain + additive_correction;
%                     multiplicative_correction = ((sign_check < 0).* limit_check * mul_const) + (sign_check >= 0);
%                     obj.hidden(L,1).gain = obj.hidden(L,1).gain .* multiplicative_correction;                    
                    
                    obj.hidden(L,1).del_w = (eta * obj.hidden(L,1).gain) .* obj.hidden(L,1).step_direction;
                    obj.hidden(L,1).weights =...
                    obj.hidden(L,1).weights + (mu * obj.hidden(L,1).del_w_prev) + obj.hidden(L,1).del_w;  
                end         
            end
            
            % for output layer
%             synaptic_weights = synaptic_weights + obj.out_arg*obj.hidden_layer_neurons;

            L = obj.hidden_layers;
            eta = eta_0/sqrt(L*obj.hidden_layer_neurons);% * 1/sqrt(synaptic_weights);     
            add_const = eta/5;
            out_prev_l = [obj.hidden(L).a_out; 1] * ones(1, obj.out_arg);
            local_gradient = ones(neurons+1,1) * obj.output.local_gradient';

            obj.output.del_w_prev = obj.output.del_w;
            obj.output.step_direction_prev = obj.output.step_direction;
            obj.output.step_direction = local_gradient .* out_prev_l;

%             sign_check = obj.output.del_w_prev .* obj.output.del_w;
%             limit_check = (obj.output.gain <= upper) .* (obj.output.gain >= lower);
%             additive_correction = (sign_check > 0) .* limit_check * add_const;
%             obj.output.gain = obj.output.gain + additive_correction;
%             multiplicative_correction = ((sign_check < 0).* limit_check * mul_const) + (sign_check >= 0);
%             obj.output.gain = obj.output.gain .* multiplicative_correction;

            obj.output.del_w = (eta * obj.output.gain) .* obj.output.step_direction;
            obj.output.weights =...
            obj.output.weights + (mu * obj.output.del_w_prev) + obj.output.del_w;             
        end
%%%%%-----------------------------------------------------------------%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end