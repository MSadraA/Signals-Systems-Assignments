function grayImage = mygrayfun(image)
    redChannel = image(:,:,1);
    blueChannel = image(:,:,2);
    greenChannel = image(:,:,3);
     
    grayChannel = (0.299* double(redChannel)) + (0.578* double(greenChannel)) + (0.114*double(blueChannel));
    grayImage = uint8(grayChannel);
end

