function cleanMask = clean_foreground(currGray, prevGray, diffThresh, closeSize, minArea)
    % Initialize foreground extraction based on motion and edges
    
    % 1. Motion Detection via Frame Differencing
    diffImg = abs(double(currGray) - double(prevGray));
    motionMask = diffImg > diffThresh; 
    
    % 2. Spatial Edge Detection using Sobel operator
    edgeMask = edge(currGray, 'sobel');
    
    % Dilate edges to bridge small gaps and form continuous vehicle structures
    dilatedEdges = imdilate(edgeMask, strel('disk', 5));
    
    % 3. Intersection of Motion and Structural Edges
    rawMask = motionMask & dilatedEdges;
    
    % 4. Morphological Cleaning and Closing
    rawMask = imopen(rawMask, strel('disk', 2));
    rawMask = imclose(rawMask, strel('rectangle', closeSize));
    rawMask = imfill(rawMask, 'holes');
    
    % 5. Remove Small Noise Regions based on Area Threshold
    cleanMask = bwareaopen(rawMask, minArea);
    
    % 6. One-Sided Downward Expansion (To guarantee the license plate is included)
    padBottom = 40; % Number of pixels to expand downwards
    padSides = 15;  % Number of pixels to expand horizontally
    
    halfPad = round(padBottom / 2);
    
    % Create symmetric structuring element for initial expansion
    se = strel('rectangle', [halfPad * 2 + 1, padSides]);
    dilatedMask = imdilate(cleanMask, se);
    
    % Shift the expanded mask downwards to restore the top edge and stretch the bottom edge
    shiftedMask = imtranslate(dilatedMask, [0, halfPad]);
    
    % Combine with the original clean mask to finalize the region
    cleanMask = cleanMask | shiftedMask;
    
end