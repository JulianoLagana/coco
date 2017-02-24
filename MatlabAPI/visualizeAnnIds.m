function [ ] = visualizeAnnIds( coco, ids, imgPath, dataType)
% Visualize the mask and bboxes of all annotation ids provided in 'ids'.
%
% Inputs
% coco : the coco API object, returned by the function CocoApi().
% ids : array of annotation ids.
% imgPath (optional) : the path to the image locations
% dataType (optional) : from which dataset to load the images
%
% Output
% ~

    % Default values initialization
    switch nargin
        case 2
            imgPath = '../images';
            dataType = 'train2014';
        case 3 
            dataType = 'train2014';        
    end
    

    % Assign a perceptually different color for each category
    cat_colors = distinguishable_colors(90,{'w','k'});
    figure('units','normalized','outerposition',[0 0 1 1]);

    % For each annotation id in ids
    for i = 1 : numel(ids)

        % Load the annotation
        annId = ids(i);
        ann = coco.loadAnns(annId);

        % Load the corresponding image
        img = coco.loadImgs(ann.image_id);
        I = imread(sprintf('%s/%s/%s',imgPath, dataType,img.file_name));

        % Show the image
        imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[])
        title(ann.image_id);
        title(int2str(ann.id));

        % Show mask and bounding box of the filtered annotation
        coco.showAnns(ann);
        cat = ann.category_id;
        bbox = ann.bbox;
        rectangle('Position', bbox,'EdgeColor',cat_colors(cat,:), 'LineWidth', 3);
        cat_name = loadCats(coco,[ann.category_id]);
        text(bbox(1), bbox(2)-10, cat_name.name, 'FontSize', 10, 'Color', cat_colors(cat,:));

        % Wait for user visualization
        waitforbuttonpress;

    end


end

