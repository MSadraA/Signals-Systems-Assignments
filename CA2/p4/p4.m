% 1. Initialization & Parameters
TRAIN = load_mapset('Map set Farsi');
videoFile = 'SampleVideos/video3.avi';
vidReader = VideoReader(videoFile);
fps = vidReader.FrameRate;
dt = 1 / fps; 

% Define output video files
outputCombinedFile = 'Result/output_final.avi';          % Combined video (original frame + mask)
outputCleanFile = 'Result/output_clean.avi';             % Clean final video (vehicles and plates only)

vidWriterCombined = VideoWriter(outputCombinedFile);
vidWriterCombined.FrameRate = fps; 
open(vidWriterCombined);

vidWriterClean = VideoWriter(outputCleanFile);
vidWriterClean.FrameRate = fps; 
open(vidWriterClean);

% VideoPlayer removed for direct background video writing without frame-by-frame display

prevFrame = readFrame(vidReader);
prevGray = rgb2gray(prevFrame);
prevCentroids = []; 
diffThresh = 70;           
closeSize = [80, 15];      
minArea = 5000; 
vidReader.CurrentTime = 0.3;

% 2. Main Processing Loop
while hasFrame(vidReader)
    currFrame = readFrame(vidReader);
    
    % Stabilization & Foreground Extraction
    stabilizedCurr = stabilize_frame(currFrame, prevFrame);
    currGray = rgb2gray(stabilizedCurr);
    cleanMask = clean_foreground(currGray, prevGray, diffThresh, closeSize, minArea);
    
    cars = regionprops(cleanMask, 'BoundingBox', 'Centroid', 'Area');
    displayFrame = currFrame; 
    currCentroids = zeros(length(cars), 2); 
    
    % 3. Vehicle Tracking & ALPR
    for i = 1:length(cars)
        carBBox = cars(i).BoundingBox;
        currCentroid = cars(i).Centroid;
        currCentroids(i, :) = currCentroid;
        
        % Speed Estimation
        speedStr = calculate_speed(currCentroid, prevCentroids, dt, 100);
        
        % Plate Extraction & OCR
        carImg = imcrop(currFrame, carBBox);
        % imshow(carImg); % Commented out to prevent blocking batch video processing
        
        plateImg = extract_plate(carImg);
        plateText = "";
        
        if ~isempty(plateImg)
            cleanedPlate = clean_image(plateImg, 10, 110);
            % imshow(cleanedPlate); % Commented out
            plateText = read_plate_chars(cleanedPlate, TRAIN);
        end
        
        if isempty(plateText)
            plateText = 'Unknown';
        end
            
        % Draw Annotations
        displayFrame = insertShape(displayFrame, 'Rectangle', carBBox, 'Color', 'green', 'LineWidth', 3);
        textPosSpeed = [carBBox(1) + carBBox(3) + 10, carBBox(2)];
        displayFrame = insertText(displayFrame, textPosSpeed, speedStr, 'FontSize', 18, 'BoxColor', 'yellow');
        textPosPlate = [carBBox(1), max(carBBox(2) - 40, 1)];
        displayFrame = insertText(displayFrame, textPosPlate, plateText, 'FontSize', 22, 'BoxColor', 'white');
    end
    
    % 4. Update Variables & Write to Both Video Files
    prevCentroids = currCentroids; 
    maskRGB = repmat(uint8(cleanMask) * 255, [1, 1, 3]);
    combinedFrame = [displayFrame, maskRGB]; 
    
    % Write frames to both output video writers
    writeVideo(vidWriterCombined, combinedFrame);
    writeVideo(vidWriterClean, displayFrame);
    
    prevFrame = stabilizedCurr;
    prevGray = currGray;

    %step(vidPlayer, combinedFrame);
end

% Close video writers
close(vidWriterCombined);
close(vidWriterClean);

disp('Processing completed. Check output_final.avi and output_clean.avi.');