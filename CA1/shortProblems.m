clc;
clear;

% 1. Sclarar Variables
a = 10;
b = 2.5e23;
c = 2 + 3i;
d = exp(1i*2*pi/3);

% 2. Vector Variables
aVec = [3.14, 15, 9, 26];
bVec = [2.71; 8; 28; 182];
cVec = 5:-0.2:-5;
dVec = logspace(0, 1, 101);
eVec = 'Hello';

% 3. Matrix Variables
aMat = 2 * ones(9, 9);
bMat = diag([1,2,3,4,5,4,3,2,1]);
cMat = reshape(1:100,10, 10);
dMat = NaN(3, 4);
eMat = [13,-1,5;-22,10,-87];
    % using floor and rand
fMat_floor = floor(7*rand(5,3))-3;
fMat_ceil = ceil(7*rand(5,3))-4;
    % using randi
fMat_randi = randi([-3,3], 5, 3);

% 4. Scalar Equations
x = 1/(1 + exp(-(a-15)/6));
    % using nthroot
y_1 = (sqrt(a) + nthroot(b , 21))^pi;
    % uding power
y_2 = (sqrt(a) + b^(1/21))^pi;
z = log(real((c+d)*(c-d)) * sin(a*pi/3)) / (c * conj(c));

% 5. Matrix equations
xMat = (aVec*bVec)*(aMat^2);
yMat = bVec * aVec;
zMat = det(cMat) * (aMat * bMat)';

% 6. Common functions and indexing
cSum = sum(cMat);
eMean = mean(eMat,2);
eMat(1, :) = [1,1,1];
cSub = cMat(2:9, 2:9);
lin = 1:1:20;
lin(2:2:20) = -lin(2:2:20);
r = rand(1,5);
elements_idx = find(r<0.5);
r(elements_idx) = 0;
