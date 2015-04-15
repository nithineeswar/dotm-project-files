function [data] = get_texture(path_name, feature_l)
    fid = fopen(path_name, 'rb');
    data = fread(fid, inf, '*double');
    fclose(fid);
    data = reshape(data, [240 320 feature_l]);
end