function [  ] = visualizeImdb( imdb_path )

    file = matfile(imdb_path);
    figure('units','normalized','outerposition',[0 0 1 1]);
    
    % Find the number of images
    a = whos(file,'imdb');
    nImages = a.size;
    for i = 1 : nImages
        I = file.imdb(:,:,:,i);
        mask = file.masks(:,:,i);
        
        subplot(1,2,1);
        image(I);
        subplot(1,2,2);
        imagesc(mask);
        
        waitforbuttonpress;
    end


end

