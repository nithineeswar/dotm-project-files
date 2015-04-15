function [cmyk] = rgb2cmyk(img)
    cform = makecform('srgb2lab');  
    cmyk = applycform(img, cform);
end

