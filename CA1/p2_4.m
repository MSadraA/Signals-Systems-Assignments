function [alpha, beta, gama] = p2_4(x, y)
    aMat = [x.^2; x; ones(size(x))];
    xMat = aMat * aMat';
    yMat = aMat * y';
    zMat = inv(xMat) * yMat;
    
    alpha = zMat(1);
    beta = zMat(2);
    gama = zMat(3);
end