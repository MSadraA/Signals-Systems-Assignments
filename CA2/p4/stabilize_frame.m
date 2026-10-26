function stabilizedFrame = stabilize_frame(currentFrame, referenceFrame)
    currGray = rgb2gray(currentFrame);
    refGray = rgb2gray(referenceFrame);
    
    ptsRef = detectSURFFeatures(refGray);
    ptsCurr = detectSURFFeatures(currGray);
    
    [featuresRef, validPtsRef] = extractFeatures(refGray, ptsRef);
    [featuresCurr, validPtsCurr] = extractFeatures(currGray, ptsCurr);
    
    indexPairs = matchFeatures(featuresRef, featuresCurr);
    
    if length(indexPairs) > 10
        matchedRef = validPtsRef(indexPairs(:, 1));
        matchedCurr = validPtsCurr(indexPairs(:, 2));
        
        tform = estimateGeometricTransform2D(matchedCurr, matchedRef, 'affine');
        stabilizedFrame = imwarp(currentFrame, tform, 'OutputView', imref2d(size(currentFrame)));
    else
        stabilizedFrame = currentFrame; 
    end
end