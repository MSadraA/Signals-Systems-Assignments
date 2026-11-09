function output_img = xor_cipher(input_img, key16_bin)
    if length(key16_bin) ~= 16
        error('The key must be a 16-bit binary string.');
    end

    key1 = uint8(bin2dec(key16_bin(1:8)));
    key2 = uint8(bin2dec(key16_bin(9:16)));
    
    total_pixels = numel(input_img);
    key_mask = zeros(size(input_img), 'uint8');
    
    key_mask(1:2:total_pixels) = key1;
    key_mask(2:2:total_pixels) = key2;
    
    output_img = bitxor(input_img, key_mask);
end