function [ result ] = isPseudoSquareAndNotSmall( ann, squareTolerance, smallestBboxAreaAllowed )

    result1 = isPseudoSquareBbox(ann, squareTolerance);
    result2 = ann.area >= smallestBboxAreaAllowed;
    result = result1 && result2;


end

