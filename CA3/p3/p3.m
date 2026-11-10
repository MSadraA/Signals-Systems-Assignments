clc;
clear;
close all;

% 1. Select Video
[videoName, videoPath] = uigetfile( ...
    {'*.avi;*.mp4;*.mov', 'Video Files'}, 'Select Video');
if isequal(videoName, 0)
    return;
end

vidReader = VideoReader(fullfile(videoPath, videoName));
fps = vidReader.FrameRate;

% 2. Define output directories and files
resultDir = fullfile(pwd, 'Result');
if ~exist(resultDir, 'dir')
    mkdir(resultDir);
end

[~, baseName, ~] = fileparts(videoName);
outputCombinedFile = fullfile(resultDir, [baseName, '_combined.avi']);
outputCleanFile = fullfile(resultDir, [baseName, '_clean.avi']);
vidWriterCombined = VideoWriter(outputCombinedFile);
vidWriterCombined.FrameRate = fps;
open(vidWriterCombined);

vidWriterClean = VideoWriter(outputCleanFile);
vidWriterClean.FrameRate = fps;
open(vidWriterClean);

% 3. Parameters
diffThresh = 5;
closeSize = [50, 50];
maxArea = 950;
minArea = 20;

% 4. Read First Frame
prevFrame = readFrame(vidReader);
prevGray = rgb2gray(prevFrame);
prevCentroid = [];
lastBBox = [];

% 5. Main Loop (Background processing without frame-by-frame plot)
while hasFrame(vidReader)
    currFrame = readFrame(vidReader);
    
    % Image Stabilization
    currGray = rgb2gray(currFrame);
    
    % Foreground Extraction
    cleanMask = clean_foreground( ...
        currGray, prevGray, diffThresh, closeSize, minArea);
    cleanMask = clear_background(cleanMask,maxArea);
        
    % Object Detection
    objects = regionprops(cleanMask, 'BoundingBox', 'Centroid', 'Area');
        
    displayFrame = currFrame;
    
    % Aircraft Tracking
    if ~isempty(objects)
        if isempty(prevCentroid)
            [~, selectedIndex] = max([objects.Area]);
        else
            distances = zeros(length(objects), 1);
            for i = 1:length(objects)
                distances(i) = sqrt( ...
                    (objects(i).Centroid(1) - prevCentroid(1))^2 + ...
                    (objects(i).Centroid(2) - prevCentroid(2))^2);
            end
            [~, selectedIndex] = min(distances);
        end
        lastBBox = objects(selectedIndex).BoundingBox;
        prevCentroid = objects(selectedIndex).Centroid;
    end
    
    % Draw Rectangle
    if ~isempty(lastBBox)
        displayFrame = insertShape(displayFrame, ...
            'Rectangle', lastBBox, ...
            'Color', 'green', 'LineWidth', 3);
    end
    
    maskRGB = repmat(uint8(cleanMask) * 255, [1, 1, 3]);
    combinedFrame = [displayFrame, maskRGB];
    
    % Prepare Combined Frame (Display + Mask side-by-side)
    % subplot(1, 2, 1);
    % imshow(displayFrame);
    % title('Tracked Target');
    % 
    % subplot(1, 2, 2);
    % imshow(cleanMask);
    % title('Binary Mask');
    % drawnow;

    % Write frames to both output video writers
    writeVideo(vidWriterCombined, combinedFrame);
    writeVideo(vidWriterClean, displayFrame);
    
    % Update Previous Frame
    prevFrame = currFrame;
    prevGray = currGray;
end

% Close video writers
close(vidWriterCombined);
close(vidWriterClean);

disp(['Processing completed. Check the "Result" folder for:']);
disp(['1. ', [baseName, '_combined.avi']]);
disp(['2. ', [baseName, '_clean.avi']]);