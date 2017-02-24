%% Demo for the CocoApi (see CocoApi.m)

%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
dataType='train2014'; annType=annTypes{1}; % specify dataType/annType
annFile=sprintf('../annotations/%s_%s.json',annType,dataType);
coco=CocoApi(annFile);


%% Show n images

% Assign a perceptually different color for each category
cat_colors = distinguishable_colors(90,{'w','k'});
  
n = 100;
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1 : 100
    % get all images containing given categories, select one at random
    catIds = coco.getCatIds('catNms','person');
    imgIds = coco.getImgIds('catIds',catIds);
    imgId = imgIds(randi(length(imgIds)));

    % load and display image
    img = coco.loadImgs(imgId);
    I = imread(sprintf('../images/%s/%s',dataType,img.file_name));
    imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[])
    title(imgId);

    % load annotations
    annIds = coco.getAnnIds('imgIds',imgId,'iscrowd',[]);
    anns = coco.loadAnns(annIds); 

    % get category names
    cat_names = loadCats(coco,[anns.category_id]);
    cat_names = {cat_names.name};

    % display bounding boxes
    for i = 1 : numel(anns)
        cat = anns(i).category_id;
        bbox = anns(i).bbox;
        rectangle('Position', bbox,'EdgeColor',cat_colors(cat,:), 'LineWidth', 3);

        % write the cat name above the box
        text(bbox(1), bbox(2)-5, cat_names{i}, 'FontSize', 10, 'Color', cat_colors(cat,:));
    end
    waitforbuttonpress;   
    coco.showAnns(anns);
    waitforbuttonpress;
end
