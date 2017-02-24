function [ filteredAnnIds ] = filterAnns( coco, criterion)
% Search, among all images, the annotations that pass a given criterion.
%
% Inputs
% coco : the coco API object, returned by the function CocoApi()
% criterion : handle to a function that has only one argument, the
% annotation. This function should return 1 if the annotation passes the 
% criterion, 0 otherwise.
%
% Output
% filteredAnnIds : array with the ids of all annotations that passed the 
% given criterion.

    filteredAnnIds = [];

    % Get the ids of all images
    imgIds = coco.getImgIds();
    
    % For each id
    h = waitbar(0,'Filtering in progress, please wait...');
    nImgIds = numel(imgIds);
    tickProgress = round(nImgIds/10);
    for i = 1 : nImgIds
        
        imgId = imgIds(i);
        
        % Load the annotations for that image
        annIds = coco.getAnnIds('imgIds',imgId,'iscrowd',0);
        anns = coco.loadAnns(annIds);
        
        % For each annotation
        for j = 1 : numel(anns)
            
            ann = anns(j);
            
            % If this ann passes the criterion, save it
            if criterion(ann)
                filteredAnnIds = [filteredAnnIds ann.id];
            end
            
        end
        
        % Update progress
        if mod(i,tickProgress)==0
            waitbar(i/numel(imgIds));
        end
        
    end
    
    close(h);    
end

