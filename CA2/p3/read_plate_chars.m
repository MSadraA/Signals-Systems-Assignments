function plate_string = read_plate_chars(img, TRAIN)    
    % 1. Segmentation
    [L, Ne] = bwlabel(img);
    plate_string = [];
    totalLetters = size(TRAIN, 2);
    
    % 2. Character Recognition
    for n = 1:Ne
        [r, c] = find(L == n);
        Y = img(min(r):max(r), min(c):max(c));
        
        [r_y, c_y] = find(Y == 1);
        if ~isempty(r_y) && ~isempty(c_y)
            Y = Y(min(r_y):max(r_y), min(c_y):max(c_y));
        end

        %imshow(Y);
        
        Y = imresize(Y, [42, 24]);
      
        ro = zeros(1, totalLetters);
        for k = 1:totalLetters
            ro(k) = corr2(double(TRAIN{1, k}), double(Y));
        end
        
        [MAXRO, pos] = max(ro);
        if MAXRO > 0.5
            out = TRAIN{2, pos};
            plate_string = [plate_string, out];
        end
    end
end

