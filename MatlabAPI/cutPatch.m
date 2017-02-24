function [ patch ] = cutPatch( im, bbox )

    bbox = round(bbox);
    x = bbox(1) + 1;
    y = bbox(2) + 1;
    w = bbox(3); % I don't really know why this is necessary, but it is...
    h = bbox(4);
    s = size(im);
    patch = im( y:min(y+h,s(1)) , x:min(x+w,s(2)) , : );

end

