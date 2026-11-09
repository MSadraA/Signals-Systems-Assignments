
function cleanMask = clean_foreground(currGray, prevGray, diffThresh, closeSize, minArea)

    % 1. Motion Detection via Frame Differencing

    diffImg = abs(double(currGray) - double(prevGray));

    motionMask = diffImg > diffThresh;

    % 2. Spatial Edge Detection using Sobel operator

    edgeMask = edge(currGray, 'sobel');

    dilatedEdges = imdilate(edgeMask, strel('disk', 10));

    % 3. Intersection of Motion and Structural Edges

    rawMask = motionMask & dilatedEdges;

    % 4. Morphological Cleaning and Closing

    rawMask = imopen(rawMask, strel('disk', 1));

    rawMask = imclose(rawMask, strel('rectangle', closeSize));

    rawMask = imfill(rawMask, 'holes');

    % 5. Remove Small Noise Regions

    cleanMask = bwareaopen(rawMask, minArea);

end
