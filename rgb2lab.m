function [lab] = rgb2lab(img)
    img = double(img)/255;
    
    if ~exist('wp', 'var')
        wp = 'D65'; 
    end
    cform = makecform('srgb2lab', 'adaptedwhitepoint', whitepoint(wp));  
    lab = applycform(img, cform);
    
    lab(:,:,1) = lab(:,:,1) * 2.55;
    lab(:,:,2) = lab(:,:,2) + 128;
    lab(:,:,3) = lab(:,:,3) + 128;
    
    lab = lab/255;
end

