%% 1. MapSet creation
Alphabet = 'abcdefghijklmnopqrstuvwxyz .,!;''';
Mapset = cell(2, 32);

for i = 1:32
    Mapset{1, i} = Alphabet(i);
    Mapset{2, i} = dec2bin(i-1, 5);
end

%% 3. Coding function test
img = imread('Amsterdam.jpg');
if size(img, 3) == 3
    img = rgb2gray(img);
end

message = 'signal';

encodedImage = coding(message, img, Mapset,5,5);

figure;
subplot(1, 2, 1);
imshow(img);
title('Original Image');

subplot(1, 2, 2);
imshow(encodedImage);
title('Encoded Image');

%% 4. Decoding function test
decodedMsg = decoding(encodedImage,Mapset,5,5);
disp(decodedMsg);