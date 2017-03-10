% This script creates the dataset for training. It should be run from
% inside the folder coco/MatlabAPI/

% Initialize COCO API
coco = CocoApi('../annotations/instances_train2014.json');

% Parameters for creating the dataset
w = 224;
h = 224;
squareTolerance = 10;
smallestAreaAllowed = 2000;

% Create .mat file and matfile object to write dataset
delete 'imdb.mat';
file = matfile('imdb.mat','Writable',true);

% Filter the annotations
filteredAnnIds = filterAnns(coco,@(x)isPseudoSquareAndNotSmall(x,squareTolerance,smallestAreaAllowed));

% Shuffle them
filteredAnnIds = filteredAnnIds(randperm(numel(filteredAnnIds)));

% Load the annotations
anns = coco.loadAnns(filteredAnnIds);

% Create buffer
bufferSize = 10000; % smallest possible value is 2, because of the way matfile initializes variables
clear buffer1 buffer2;
buffer1(1:w , 1:h , 3, bufferSize) = uint8(0);
buffer2(1:w , 1:h , 1, bufferSize) = uint8(0);
n = 0;
nImagesSaved = 0;

% For each annotation
progressTick = round(numel(anns)/100);
handleWaitBar = waitbar(0,'Please wait.');
for i = 1 : numel(anns)
    % Get the corresponding image
    ann = anns(i);
    imgId = ann.image_id;
    imgInfo = coco.loadImgs(imgId);
    I = imread(sprintf('../images/train2014/%s',imgInfo.file_name));
    
    % Get the mask
    mask = getMask(ann,[size(I,1) size(I,2)]);
    
    % Crop both the image and the mask to the bounding box
    I = cutPatch(I,ann.bbox);
    mask = cutPatch(mask,ann.bbox);    
    
    % Resize them 
    I = imresize(I,[w,h]); 
    mask = imresize(mask,[w,h]);
    
    % If it's a B&W image, create fake channels
    if size(I,3) == 1
        I(:,:,2) = I(:,:,1);
        I(:,:,3) = I(:,:,1);
    end
    
    % Save to buffer
    n = n + 1;
    buffer1(:,:,:,n) = I;
    buffer2(:,:,1,n) = mask;
    
    % If buffer is full, save to file and "empty" it
    if n == bufferSize
        
        % Debug
        disp('writing to file');
        % Determine if this is the first save
        varlist = whos(file);
        if numel(varlist) < 2
            % If it is, we must create the variables without using the
            % colon operator
            file.imdb = buffer1;
            file.masks = buffer2;
            n = 0;
            nImagesSaved = nImagesSaved + bufferSize;
        else
            % If not, determine how many images were already saved, and
            % start saving from there
            file.imdb(: , : , : , nImagesSaved+1 : nImagesSaved+n) = buffer1;
            file.masks(:,:, 1, nImagesSaved+1 : nImagesSaved+n) = buffer2;
            n = 0;
            nImagesSaved = nImagesSaved + bufferSize;
        end

    end
    
    % If it's the right time, update the progress bar
    if mod(i,progressTick) == 0
        progress = i/numel(anns);
        msg = sprintf('Please wait: %i%% complete',round(progress*100));
        waitbar(progress,handleWaitBar, msg);
    end
    
end   

% Empty the buffer by saving the remaining contents to file
if n > 0
    
    % Determine if this is the first save
    varlist = whos(file);
    if numel(varlist) < 2
        % If it is, we must create the variables without using the
        % colon operator
        file.imdb = buffer1(:,:,:,1:n);
        file.masks = buffer2(:,:,1,1:n);
        n = 0;
        nImagesSaved = nImagesSaved + n;
    else
        % If not, determine how many images were already saved, and
        % start saving from there
        file.imdb(: , : , : , nImagesSaved+1 : nImagesSaved+n) = buffer1(:,:,:,1:n);
        file.masks(:,:,1, nImagesSaved+1 : nImagesSaved+n) = buffer2(:,:,1,1:n);
        n = 0;
        nImagesSaved = nImagesSaved + n;
    end
    
end

close(handleWaitBar);
