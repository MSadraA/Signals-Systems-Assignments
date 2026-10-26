function plate_img = extract_plate(carImage)
    % Initialize output
    plate_img = [];
    if isempty(carImage), return; end

    % 1. Initialization, Validation and Resizing
    origImg = carImage;
    [origH, origW, C] = size(origImg);
    if origH < 40 || origW < 40, return; end

    targetW = 500;
    scale = targetW / origW;
    img = imresize(im2double(origImg), [round(origH * scale), targetW]);
    [H, W, ~] = size(img);

    % 2. Color Channel Processing & Text Energy Map
    if C == 3
        gray = rgb2gray(img);
        % Extract pure blue channel map (for the blue strip on Iranian plates)
        blueMap = max(0, img(:,:,3) - max(img(:,:,1), img(:,:,2)));
    else
        gray = img;
        blueMap = zeros(H, W);
    end

    % Extract horizontal text energy while suppressing vertical grid lines (e.g., grilles)
    horizDiff = abs(conv2(gray, [-1, 0, 1], 'same'));
    vertDiff  = abs(conv2(gray, [-1; 0; 1], 'same'));
    textEnergy = max(0, horizDiff - 0.5 * vertDiff);

    % 3. Integral Images for Fast Box Summation
    intEnergy = integralImage(textEnergy);
    intGray   = integralImage(gray);
    intBlue   = integralImage(blueMap);

    % 4. Sliding Window Multi-Scale Search & Scoring
    plateWidths = round(W * [0.22, 0.28, 0.35]); 
    aspectRatios = [3.8, 4.5]; % 3.8 for top-down angle, 4.5 for frontal view
    
    bestScore = -Inf;
    bestBox = [];
    
    % Define search region in the lower half of the image
    yMin = round(H * 0.45);
    yMax = round(H * 0.94);
    xMin = round(W * 0.12);
    xMax = round(W * 0.88);

    for pw = plateWidths
        for ar = aspectRatios
            ph = round(pw / ar);
            if yMax - ph <= yMin || xMax - pw <= xMin, continue; end

            % Generate search grid with a step size of 3 pixels for speed
            [X, Y] = meshgrid(xMin : 3 : (xMax - pw), yMin : 3 : (yMax - ph));
            area = pw * ph;

            % A) Mean text energy inside the candidate window
            sumEnergy = rectSum(intEnergy, X, Y, pw, ph) / area;

            % B) Central core brightness (to reject dark grilles and bumpers)
            inX = X + round(pw * 0.15);
            inY = Y + round(ph * 0.15);
            inW = round(pw * 0.75);
            inH = round(ph * 0.70);
            meanBright = rectSum(intGray, inX, inY, inW, inH) / (inW * inH);

            % C) Blue stripe presence in the left 22% of the window
            blueW = round(pw * 0.22);
            meanBlue = rectSum(intBlue, X, Y, blueW, ph) / (blueW * ph);

            % D) Spatial biases (favoring horizontal center and lower image regions)
            centerBias = 1 - abs((X + pw/2)/W - 0.5);
            verticalBias = (Y / H);

            % Final score calculation using multi-feature combination
            scoreMap = (sumEnergy) .* (meanBright .^ 2) .* (1 + meanBlue * 20) .* verticalBias .* centerBias;

            [maxVal, idx] = max(scoreMap(:));
            if maxVal > bestScore
                bestScore = maxVal;
                bestBox = [X(idx), Y(idx), pw, ph];
            end
        end
    end

    % 5. Mapping Coordinates, Asymmetric Padding & Cropping
    if ~isempty(bestBox)
        % Apply asymmetric padding to preserve characters and plate edges
        padLeft  = max(bestBox(3) * 0.12, bestBox(4) * 0.30);
        padRight = max(bestBox(3) * 0.25, bestBox(4) * 0.60);
        padY     = bestBox(4) * 0.15;

        x1 = floor(bestBox(1) - padLeft);
        y1 = floor(bestBox(2) - padY);
        x2 = ceil(bestBox(1) + bestBox(3) - 1 + padRight);
        y2 = ceil(bestBox(2) + bestBox(4) - 1 + padY);

        % Bound coordinates within the resized working image limits
        x1 = max(1, x1);
        y1 = max(1, y1);
        x2 = min(W, x2);
        y2 = min(H, y2);

        scaleX = W / origW;
        scaleY = H / origH;

        % Map coordinates back to the original full-resolution image
        bx = max(1, floor((x1 - 1) / scaleX) + 1);
        by = max(1, floor((y1 - 1) / scaleY) + 1);
        ex = min(origW, ceil((x2 - 1) / scaleX) + 1);
        ey = min(origH, ceil((y2 - 1) / scaleY) + 1);

        % Crop the final plate region from the original image
        if ex >= bx && ey >= by
            if ndims(origImg) == 2
                plate_img = origImg(by:ey, bx:ex);
            else
                plate_img = origImg(by:ey, bx:ex, :);
            end
        end
    end
end

% Helper function using sub2ind for fast matrix lookups via integral images
function s = rectSum(ii, X, Y, w, h)
    sz = size(ii);
    idx1 = sub2ind(sz, Y + h, X + w);
    idx2 = sub2ind(sz, Y,     X + w);
    idx3 = sub2ind(sz, Y + h, X);
    idx4 = sub2ind(sz, Y,     X);
    s = ii(idx1) - ii(idx2) - ii(idx3) + ii(idx4);
end