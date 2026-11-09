function decodedMessage = decoding(encodedImage, Mapset, BLOCKROW, BLOCKCOL)
    BLOCKSIZE = BLOCKROW * BLOCKCOL;
    
    [rows, cols] = size(encodedImage);
    block_rows = floor(rows / BLOCKROW);
    block_cols = floor(cols / BLOCKCOL);
    
    block_info = zeros(block_rows * block_cols, 3);
    idx = 1;
    for r = 1:block_rows
        for c = 1:block_cols
            block = extract_block(encodedImage, r, c, BLOCKROW, BLOCKCOL);
            
            robust_block = bitand(block, 254);
            v = var(double(robust_block(:)));
            
            block_info(idx, :) = [v, r, c];
            idx = idx + 1;
        end
    end
    
    [~, sort_idx] = sort(block_info(:, 1), 'descend');
    sorted_blocks = block_info(sort_idx, :);
    
    decodedMessage = '';
    current_char_bits = '';
    
    for i = 1:size(sorted_blocks, 1)
        r = sorted_blocks(i, 2);
        c = sorted_blocks(i, 3); 
        
        block = extract_block(encodedImage, r, c, BLOCKROW, BLOCKCOL);
        
        for p = 1:BLOCKSIZE
            bit = bitget(block(p), 1);
            current_char_bits = [current_char_bits, num2str(bit)];
            
            % Every 5 bits represent one character
            if length(current_char_bits) == 5
                map_idx = find(strcmp(Mapset(2,:), current_char_bits));
                
                if isempty(map_idx)
                    warning('Invalid 5-bit sequence encountered.');
                    return;
                end
                
                char_found = Mapset{1, map_idx};
                
                if char_found == ';' 
                    return;
                else
                    decodedMessage = [decodedMessage, char_found];
                end
                current_char_bits = '';
            end
        end
    end
end

function block = extract_block(img, row, col, BLOCKROW, BLOCKCOL)
    r_start = (row-1)*BLOCKROW+1;
    r_end = row*BLOCKROW;
    c_start = (col-1)*BLOCKCOL+1;
    c_end = col*BLOCKCOL;
    block = img(r_start:r_end, c_start:c_end);
end