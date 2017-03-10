function mask = occludeMask( mask, bbox )

    bbox = round(bbox);
    x = bbox(1) + 1;
    y = bbox(2) + 1;
    w = bbox(3);
    h = bbox(4);
    mask(y:y+h, x:x+w) = -1;    

end

