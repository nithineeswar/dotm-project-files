function [block_size, blocks r_l, c_l] = get_block_size(p)
    if p == 0
        block_size = [1 1];
        r_l = 240;
        c_l = 320;
        blocks = [240 320];
    else
        block_size = [24 32]/(2^(p-1));
        r_l = 240/block_size(1,1);
        c_l = 320/block_size(1,2);
        blocks = ['b_' num2str(r_l*c_l)];
    end
end

