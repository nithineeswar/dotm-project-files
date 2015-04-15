classdef edge_filter
    properties
        vertical = [1 -1; 1 -1];
        horizontal = [1 1; -1 -1];
        directional_45 = [sqrt(2) 0; 0 -sqrt(2)];
        directional_135 = [0 sqrt(2); -sqrt(2) 0];
        non_directional = [2 -2; -2 2];
    end
end