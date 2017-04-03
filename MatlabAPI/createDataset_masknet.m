% Create centered dataset
DEBUG = 0;

% Initialize COCO API
coco = CocoApi('../annotations/instances_train2014.json');

% Parameters for creating the dataset
w = 224;
h = 224;
squareTolerance = 4;
smallestAreaAllowed = 2000;
intersectionThreshold = 0.3;
rng(0);

% Create .mat file and matfile object to write dataset
delete 'centered_imdb.mat';
file = matfile('centered_imdb.mat');

% Get all image ids and shuffle them
imgIds = coco.getImgIds();
imgIds = imgIds(randperm(numel(imgIds)));

% Create buffer
bufferSize = 50; % smallest possible value is 2, because of the way matfile initializes variables
shuffleIdx = randperm(bufferSize);
clear buffer1 buffer2 buffer3;
buffer1(1:w , 1:h , 3, bufferSize) = uint8(0);
buffer2(1:w , 1:h , 1, bufferSize) = int8(0);
buffer3(1:w , 1:h , 1, bufferSize) = int8(0);
n = 0;
nImagesSaved = 0;

% For each image
progressTick = round(numel(imgIds)/100);
handleWaitBar = waitbar(0,'Please wait.');
for i = 1 : numel(imgIds)
    
   disp(['Processing image: ' num2str(i)]);
   
   % Load the image
   img = coco.loadImgs(imgIds(i));
   Io = imread(sprintf('../images/train2014/%s',img.file_name));
   
   % Load its annotations
   annIds = coco.getAnnIds('imgIds',imgIds(i),'iscrowd',0);
   anns = coco.loadAnns(annIds);
   
   % Debug mode: display image and annotations, with numbers
   if DEBUG
       cat_colors = distinguishable_colors(90,{'w','k'});
       image(Io); axis('image'); set(gca,'XTick',[],'YTick',[])
       title(imgIds(i));
       % display bounding boxes
       for b = 1 : numel(anns)
           cat = anns(b).category_id;
           bbox = anns(b).bbox;
           rectangle('Position', bbox,'EdgeColor',cat_colors(cat,:), 'LineWidth', 3);

           % write the cat number above the box
           text(bbox(1), bbox(2)-10, num2str(b), 'FontSize', 20, 'Color', cat_colors(cat,:));
       end
   end
   
   for j = 1 : numel(anns)
      
      % Discard examples that do not fit squareness and area criteria
      if ~isPseudoSquareAndNotSmall(anns(j),squareTolerance,smallestAreaAllowed)
          continue;
      end
      
      % Get the mask for the current annotation
      masko = getMask(anns(j),[size(Io,1) size(Io,2)]);
      
      % Compare this annotation to all other annotations except itself
      others = 1:numel(anns);
      others(j) = [];
      for k = others
         
        % If the bboxes intersect enough
        area = anns(j).bbox(3)*anns(j).bbox(4);
        intersection = rectint(anns(j).bbox, anns(k).bbox)/area;          
        if intersection >= intersectionThreshold
            
            % Occlude the mask with the other bounding box
            partial_mask = occludeMask(masko,anns(k).bbox);

            % Crop the image, the partial mask and the ground truth to the 
            % bounding box
            I = cutPatch(Io,anns(j).bbox);
            partial_mask = cutPatch(partial_mask,anns(j).bbox);  
            ground_truth = cutPatch(masko,anns(j).bbox);

            % Resize them 
            I = imresize(I,[w,h]); 
            partial_mask = imresize(partial_mask,[w,h],'nearest');
            ground_truth = imresize(ground_truth,[w,h],'nearest');

            % If it's a B&W image, create fake channels
            if size(I,3) == 1
               I(:,:,2) = I(:,:,1);
               I(:,:,3) = I(:,:,1);
            end
            
            % Save example to buffer
            n = n + 1;
            buffer1(:,:,:,shuffleIdx(n)) = I;
            pm = int8(partial_mask);
            gt = int8(ground_truth);
            pm(pm == 0) = -1;
            gt(gt == 0) = -1;            
            buffer2(:,:,1,shuffleIdx(n)) = pm;            
            buffer3(:,:,1,shuffleIdx(n)) = gt;

            
            % If buffer is full, save to file and "empty" it
            if n == bufferSize

                % Debug
                disp('writing to file');
                % Determine if this is the first save
                varlist = whos(file);
                if numel(varlist) < 3
                    % If it is, we must create the variables without using the
                    % colon operator
                    file.imdb = buffer1;
                    file.partial_masks = buffer2;
                    file.masks = buffer3;
                    n = 0;
                    nImagesSaved = nImagesSaved + bufferSize;
                    shuffleIdx = randperm(bufferSize);
                else
                    % If not, determine how many images were already saved, and
                    % start saving from there
                    file.imdb(: , : , : , nImagesSaved+1 : nImagesSaved+n) = buffer1;
                    file.partial_masks(:,:, 1, nImagesSaved+1 : nImagesSaved+n) = buffer2;
                    file.masks(:,:, 1, nImagesSaved+1 : nImagesSaved+n) = buffer3;
                    n = 0;
                    nImagesSaved = nImagesSaved + bufferSize;
                    shuffleIdx = randperm(bufferSize);
                end

            end

         end
          
      end
       
   end
   
    % If it's the right time, update the progress bar
    if mod(i,progressTick) == 0
        progress = i/numel(imgIds);
        msg = sprintf('Please wait: %i%% complete',round(progress*100));
        waitbar(progress,handleWaitBar, msg);
    end
    
end

% Empty the buffer by saving the remaining contents to file
if n > 0
    
    % Remove elements that are not from the current save
    idxsSaved = sort(shuffleIdx(1:n));
    buffer1 = buffer1(:,:,:,idxsSaved);
    buffer2 = buffer2(:,:,1,idxsSaved);
    buffer3 = buffer3(:,:,1,idxsSaved);
    
    % Determine if this is the first save
    varlist = whos(file);
    if numel(varlist) < 3
        % If it is, we must create the variables without using the
        % colon operator
        file.imdb = buffer1;
        file.partial_masks = buffer2;
        file.masks = buffer3;
        n = 0;
        nImagesSaved = nImagesSaved + n;
    else
        % If not, determine how many images were already saved, and
        % start saving from there
        file.imdb(: , : , : , nImagesSaved+1 : nImagesSaved+n) = buffer1(:,:,:,1:n);
        file.partial_masks(:,:, 1, nImagesSaved+1 : nImagesSaved+n) = buffer2(:,:,1,1:n);
        file.masks(:,:, 1, nImagesSaved+1 : nImagesSaved+n) = buffer3(:,:,1,1:n);
        n = 0;
        nImagesSaved = nImagesSaved + n;
    end
    
end

close(handleWaitBar);
