function finalMask = clear_background(inputMask, maxArea)
    largeObjects = bwareaopen(inputMask, maxArea + 1);
    finalMask = inputMask & ~largeObjects;
end