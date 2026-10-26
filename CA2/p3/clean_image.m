function cleanImage = clean_image(picture,noiseSize,backGroundSize)
if size(picture, 3) == 3
    grayImage = rgb2gray(picture);
else
    grayImage = picture;
end
level = graythresh(grayImage);
binaryImage = imbinarize(grayImage, level);
binaryImage = ~binaryImage; 

cleanImage = bwareaopen(binaryImage, noiseSize);
largeObjects = bwareaopen(cleanImage, backGroundSize);
cleanImage = cleanImage & ~largeObjects;
end

