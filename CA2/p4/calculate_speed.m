function speedStr = calculate_speed(currCentroid, prevCentroids, dt, maxDist)
    speedStr = '0 px/s';
    
    if ~isempty(prevCentroids)
        distances = sqrt((prevCentroids(:, 1) - currCentroid(1)).^2 + (prevCentroids(:, 2) - currCentroid(2)).^2);                                          
        [minDist, ~] = min(distances);
        
        if minDist < maxDist
            speed = minDist / dt; 
            speedStr = sprintf('%.1f px/s', speed);
        end
    end
end