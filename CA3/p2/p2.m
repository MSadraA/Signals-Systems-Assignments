clc; clear; close all;

img = imread('Amsterdam.jpg');
if size(img, 3) == 3
    img = rgb2gray(img);
end

key16_bin = '1011001111001010';

encrypted_img = xor_cipher(img, key16_bin);
decrypted_img = xor_cipher(encrypted_img, key16_bin);

figure;
subplot(1, 3, 1);
imshow(img);
title('Original Image');

subplot(1, 3, 2);
imshow(encrypted_img);
title('Encrypted Image');

subplot(1, 3, 3);
imshow(decrypted_img);
title('Decrypted Image');