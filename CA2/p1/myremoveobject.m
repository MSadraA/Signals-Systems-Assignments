function cleanImage = myremoveobject(n, image)
    connectedComp = bwconncomp(image);
    cleanImage = image;
    for i = 1: connectedComp.NumObjects
        if length(connectedComp.PixelIdxList{i}) < n
            cleanImage(connectedComp.PixelIdxList{i}) = 0; 
        end
    end
end