function plate_img = extract_plate(carImage)
    carImage = imresize(carImage, [600, 800]); 
        %% 1. Preprocessing & VERTICAL Edge Detection
    if size(carImage, 3) == 3
        grayImage = rgb2gray(carImage);
    else
        grayImage = carImage;
    end
    
    [~, threshold] = edge(grayImage, 'sobel', 'vertical');
    edgeImage = edge(grayImage, 'sobel', threshold * 0.8, 'vertical'); 
    
    %% 2. Morphological Operations
    se = strel('rectangle', [12, 35]); 
    morphImage = imclose(edgeImage, se);
    morphImage = imfill(morphImage, 'holes'); 
    morphImage = bwareaopen(morphImage, 1000); 
    
    %% 3. Geometric Filtering & Extraction
    cc = bwconncomp(morphImage);
    stats = regionprops(cc, 'BoundingBox', 'Area');
    
    plate_img = [];   
    imshow(carImage);
    for i = 1:cc.NumObjects
        bb = stats(i).BoundingBox; % [x, y, width, height]
        w = bb(3);
        h = bb(4);
        aspect_ratio = w / h;
        
        if aspect_ratio > 2.5 && aspect_ratio < 6.5 && w > 80 && w < 400 && h > 20
            rectangle('Position', bb, 'EdgeColor', 'g', 'LineWidth', 3);
            plate_img = imcrop(carImage, bb);
            break; 
        end
    end
end