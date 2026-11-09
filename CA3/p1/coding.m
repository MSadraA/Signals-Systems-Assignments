function encodedImage = coding(message, img, Mapset,BLOCKROW,BLOCKCOL)
    BLOCKSIZE = BLOCKCOL * BLOCKROW;
    
    if message(end) ~= ';'
        message = [message, ';'];
    end
    
    message_bin = '';
    for i = 1:length(message)
        idx = find(strcmp(Mapset(1,:), message(i)));
        if isempty(idx)
            error(['Invalid character: ', message(i)]);
        end
        message_bin = [message_bin, Mapset{2, idx}];
    end
    message_len = length(message_bin);
    needed_blocks = ceil(message_len/BLOCKSIZE);
    
    [rows, cols] = size(img);
    block_rows = floor(rows / BLOCKROW);
    block_cols = floor(cols / BLOCKCOL);
    
    % Store variance, row, and col
    block_info = zeros(block_rows*block_cols, 3);
    idx = 1;
    for r = 1:block_rows
        for c = 1:block_cols
            block = extract_block(img, r, c, BLOCKROW, BLOCKCOL);
            
            % Clear LSB for robust variance calculation
            robust_block = bitand(block, 254);
            
            v = var(double(robust_block(:)));
            block_info(idx,:) = [v, r, c];
            idx = idx+1;
        end
    end
    
    [~, sort_idx] = sort(block_info(:, 1), 'descend');
    sorted_blocks = block_info(sort_idx, :);
    
    if needed_blocks > size(sorted_blocks, 1)
        error('Binary message length exceeds the number of selected block pixels.');
    end
    
    selected_blocks = sorted_blocks(1:needed_blocks, 2:3);
    
    encodedImage = img;
    bit_idx = 1;
    
    for i = 1:needed_blocks
        r = selected_blocks(i, 1);
        c = selected_blocks(i, 2);
        
        block = extract_block(encodedImage, r, c, BLOCKROW, BLOCKCOL);
        
        for p = 1:BLOCKSIZE
            if bit_idx > message_len
                break;
            end
            
            msg_bit = message_bin(bit_idx) - '0';
            block(p) = bitset(block(p), 1, msg_bit); 
            
            bit_idx = bit_idx + 1;
        end
        
        encodedImage = insert_block(encodedImage, block, r, c, BLOCKROW, BLOCKCOL);
    end
end

function block = extract_block(img, row, col, BLOCKROW, BLOCKCOL)
    r_start = (row-1)*BLOCKROW+1;
    r_end = row*BLOCKROW;
    c_start = (col-1)*BLOCKCOL+1;
    c_end = col*BLOCKCOL;
    block = img(r_start:r_end, c_start:c_end);
end

function img = insert_block(img, block, row, col, BLOCKROW, BLOCKCOL)
    r_start = (row-1)*BLOCKROW+1;
    r_end = row*BLOCKROW;
    c_start = (col-1)*BLOCKCOL+1;
    c_end = col*BLOCKCOL;
    img(r_start:r_end, c_start:c_end) = block;
end