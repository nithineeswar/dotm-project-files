function [f_prime] = activation_prime(a_out, str)
    L = size(a_out);
    if strcmp(str, 'tanh')
        [a, b, y] = activate(0, 'tanh');
        f_prime = b/a * ((a*ones(L(1,1),1) - a_out) .* (a*ones(L(1,1),1) + a_out));
    else
        if strcmp(str, 'logsig')
            [a, b, y] = activate(0, 'logsig');
            f_prime = b * a * (a_out .* (ones(L(1,1),1) - a_out));
        else
            display([str ' not found in activate.m']);
        end
    end
end