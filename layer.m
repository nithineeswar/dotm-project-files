classdef layer
    properties
        weights; %including bias
        gain;
        a_out;
        f_prime;
        local_error;
        local_gradient;
        step_direction;
        step_direction_prev;
        del_w;
        del_w_prev;
    end
end