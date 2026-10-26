clc
clear;

%% 1. Image Selection and Preprocessing
[file, path] = uigetfile({'*.jpg;*.bmp;*.png;*.tif'}, 'Choose an image');
s = [path, file];
picture = imread(s);
picture = imresize(picture, [300, 500]);

%% 2. Color to Grayscale and Binarization Conversion
grayImage = mygrayfun(picture);
%imshow(grayImage);
threshold = 100;
binaryImage = mybinaryfun(threshold, grayImage);
imshow(binaryImage);
%% 3. Noise Removal and Filtering Small Objects
cleanImage = myremoveobject(380, binaryImage);
imshow(cleanImage);

%% 4. Image Segmentation to Separate Characters
[L, Ne] = mysegmentation(cleanImage);

%% 5. Load Template Map Set for Recognition
files = dir('Map Set');
files([1, 2]) = [];
len = length(files);
TRAIN = cell(2, len);
for i = 1:len
   TRAIN{1, i} = imread(fullfile('Map Set', files(i).name));
   TRAIN{2, i} = files(i).name(1);
end

%% 6. Decision Making, Template Matching, and Plate Extraction
final_output = [];
for n = 1:Ne
    [r, c] = find(L == n);
    Y = cleanImage(min(r):max(r), min(c):max(c));
    %imshow(Y);
    Y = imresize(Y, [42, 24]);
    
    totalLetters = size(TRAIN, 2);
    ro = zeros(1, totalLetters);
    for k = 1:totalLetters
        ro(k) = corr2(double(TRAIN{1, k}), double(Y));
    end
    
    [MAXRO, pos] = max(ro);
    if MAXRO > 0.5
        out = TRAIN{2, pos};
        final_output = [final_output, out];
    end
end
disp(['Detected License Plate: ', final_output]);

%% 7. Save Final Result to a Text File
fileID = fopen('plate_result.txt', 'w');
fprintf(fileID, '%s\n', final_output);
fclose(fileID);