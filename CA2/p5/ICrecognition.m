function ICrecognition(ICImage, PCBImage)
    figure;
    imshow(PCBImage);
    hold on;
    
    % Convert to grayscale
    if size(ICImage, 3) == 3
        ic_gray = rgb2gray(ICImage);
    else
        ic_gray = ICImage;
    end
    
    if size(PCBImage, 3) == 3
        pcb_gray = rgb2gray(PCBImage);
    else
        pcb_gray = PCBImage;
    end
    
    threshold = 0.7;
    
    % Without rotation
    [ic_h, ic_w] = size(ic_gray);
    corr = normxcorr2(ic_gray, pcb_gray);
    
    [y_peaks, x_peaks] = find(corr >= threshold);
    
    for i = 1:length(x_peaks)
        x = x_peaks(i) - ic_w;
        y = y_peaks(i) - ic_h;
        rectangle('Position', [x, y, ic_w, ic_h], 'EdgeColor', 'b', 'LineWidth', 2);
    end
    
    % With rotation (180 degrees)
    ICImageRotated = imrotate(ic_gray, 180);
    corr_180 = normxcorr2(ICImageRotated, pcb_gray);
    
    [y_peaks_180, x_peaks_180] = find(corr_180 >= threshold);
    
    for i = 1:length(x_peaks_180)
        x = x_peaks_180(i) - ic_w;
        y = y_peaks_180(i) - ic_h;
        rectangle('Position', [x, y, ic_w, ic_h], 'EdgeColor', 'b', 'LineWidth', 2);
    end
    
    hold off;
end