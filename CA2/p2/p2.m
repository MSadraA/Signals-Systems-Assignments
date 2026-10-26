clc;
clear;
close all;

%% 1. Image Selection
[file, path] = uigetfile({'*.jpg;*.jpeg;*.bmp;*.png;*.tif'}, 'Choose an Iranian plate image');
if isequal(file, 0)
    return;
end
picture = imread(fullfile(path, file));
picture = imresize(picture, [300, 500]);

%% 2. Load Database
TRAIN = load_mapset('Map set Farsi');

%% 3. Image Cleanup
cleanImage = clean_image(picture, 600, 6000);
imshow(cleanImage);

%% 4. Read Plate Characters
final_output = read_plate_chars(cleanImage, TRAIN);

%% 5. Display and Save Result
disp(['Detected License Plate: ', final_output]);

fileID = fopen('plate_result_p2.txt', 'w', 'n', 'UTF-8');
fprintf(fileID, '%s\n', final_output);
fclose(fileID);