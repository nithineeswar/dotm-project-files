function [xyz] = rgb2xyz(img)
    if ~exist('wp', 'var')
        wp = 'D65'; 
    end
    cform = makecform('srgb2lab', 'adaptedwhitepoint', whitepoint(wp));  
    xyz = applycform(img, cform);
end

