function [ mask ] = getMask( ann, imgSize )

    w = imgSize(1);
    h = imgSize(2);
    R = MaskApi.frPoly(ann.segmentation,w,h);
    mask = MaskApi.decode(R);
    
    % Conform to matconvnet expectations
    mask = single(mask);
    mask(mask == 0) = -1;


end

