function [ result ] = isPseudoSquareBbox( ann, tolerance)

    w = ann.bbox(3);
    h = ann.bbox(4);
    if 1/tolerance <= w/h && w/h <= tolerance
        result = 1;
    else
        result = 0;
    end

end

