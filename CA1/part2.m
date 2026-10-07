clc;
clear;

%% Load input x(t), output y(t), and time vector (t) from the workspace file
load("p2.mat");

%% Problem 2-1: Plot the input signal x(t)
figure;
plot(t,x);
xlabel('t');
ylabel('x(t)');
title('Input x(t) over time');
grid on;

%% Problem 2-2: Plot the noisy output signal y(t)figure;
plot(t,y);
xlabel('t');
ylabel('y(t)');
title('Output y(t) over time');
grid on;

%% Problem 2-3: Scatter plot of y(t) versus x(t)figure;
plot(x, y, '.');
xlabel('x(t)');
ylabel('y(t)');
xlim([-2, 2]);
title('y(t) over x(t)');
grid on;

%% Problem 2-4: Test estimated alpha,beta and gama
xVec = 0:0.01:10;
alpha = 2.5;
beta = -3;
gama = 1.5;

noise = 0.1 * randn(size(xVec));
yVec = alpha*(xVec.^2) + beta*xVec + gama + noise; 

[alphaEst , betaEst , gamaEst] = p2_4(xVec,yVec);
disp(["estimated alpha = " + alphaEst ; "estimated beta = " + betaEst ; "estimated gama = " + gamaEst]);

%% Problem 2-5:
[alphaEst , betaEst , gamaEst] = p2_4(x,y);
disp(["estimated alpha = " + alphaEst ; "estimated beta = " + betaEst ; "estimated gama = " + gamaEst]);
