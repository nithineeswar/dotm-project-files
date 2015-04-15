function [a, b, activation_out] = activate(in, str)
    if strcmp(str, 'tanh')
        a = 1.7159;
        b = 2/3;
        x = 2 * b * in;
        activation_out = a * tanh(x);
    else
        if strcmp(str, 'logsig')
            a = 1;%2/3;
            b = 1.7159;
            x = a * in;
            activation_out = logsig(x);        
        end
    end
    
end