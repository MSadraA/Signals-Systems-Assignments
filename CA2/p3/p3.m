clc;
clear;
close all;

%% 1. Load and Resize Image
[file, path] = uigetfile({'*.jpg;*.jpeg;*.bmp;*.png'}, 'Choose a car image');
if isequal(file, 0)
    return;
end
carImage = imread(fullfile(path, file));
carImage = imresize(carImage, [600, 800]); 

%% 2. Extract plate
plateImage = extract_plate(carImage);
%imshow(plateImage);

%% 3. Image cleanup
plateImage = imresize(plateImage, [300, 500]);
%figure; imshow(plateImage);
cleanImage = clean_image(plateImage, 900, 6000);
figure; imshow(cleanImage);

%% 4. Load data base
TRAIN = load_mapset('Map set Farsi');

%% 5. Read Plate Characters
final_output = read_plate_chars(cleanImage, TRAIN);

%% 6. Display and Save Result
disp(['Detected License Plate: ', final_output]);

fileID = fopen('plate_result_p2.txt', 'w', 'n', 'UTF-8');
fprintf(fileID, '%s\n', final_output);
fclose(fileID);