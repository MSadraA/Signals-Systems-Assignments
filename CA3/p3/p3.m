

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

% 2. Parameters

diffThresh = 5;
closeSize = [15, 15];
minArea = 0;

% 3. Read First Frame

prevFrame = readFrame(vidReader);
prevGray = rgb2gray(prevFrame);

prevCentroid = [];
lastBBox = [];

figure;

% 4. Main Loop

while hasFrame(vidReader)

    currFrame = readFrame(vidReader);

    % Image Stabilization

    stabilizedCurr = stabilize_frame(currFrame, prevFrame);
    currGray = rgb2gray(stabilizedCurr);

    % Foreground Extraction

    cleanMask = clean_foreground( ...
        currGray, prevGray, diffThresh, closeSize, minArea);

    % Object Detection

    objects = regionprops(cleanMask, ...
        'BoundingBox', 'Centroid', 'Area');

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

    % Display Results

    subplot(1,2,1);
    imshow(displayFrame);
    title('Aircraft Tracking');

    subplot(1,2,2);
    imshow(cleanMask);
    title('Binary Mask');

    drawnow;

    % Update Previous Frame

    prevFrame = stabilizedCurr;
    prevGray = currGray;

end

disp('Tracking completed.');
