function [ im ] = cutBigPatch( im, bbox1, bbox2 )

    bbox1 = round(bbox1);
    x1 = bbox1(1) + 1;
    y1 = bbox1(2) + 1;
    ex1 = x1 + bbox1(3); 
    ey1 = y1 + bbox1(4);
    
    bbox2 = round(bbox2);
    x2 = bbox2(1) + 1;
    y2 = bbox2(2) + 1;
    ex2 = x2 + bbox2(3); 
    ey2 = y2 + bbox2(4);
    
    xmin = min(x1, x2);
    ymin = min(y1, y2);
    xmax = max(ex1, ex2); 
    ymax = max(ey1, ey2);
    
    x = xmin;
    y = ymin;
    w = xmax - xmin;
    h = ymax - ymin;
    
    bbox = [x,y,w,h];
    im = cutPatch(im, bbox);


end

