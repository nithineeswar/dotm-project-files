classdef neuron
    properties
        weights;
        bias = ones(1,1);
        w_sum_in = zeros(1,1);
        a_out = zeros(1,1);
        f_prime = zeros(1,1);
        local_error = zeros(1,1);
        local_gradient = zeros(1,1);
        delta_w;
        delta_w_prev;
    end
end