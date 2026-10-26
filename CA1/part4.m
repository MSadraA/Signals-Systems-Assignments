%% Problem 4-1: Read audio file and determine sampling frequency
clc;
clear;

[x,fs] = audioread("my voice.wav");      

disp("Sampling frequency = " + fs + " Hz");

%% Problem 4-2: Plot, Listen, and Save Audio Signal
ts = 1/fs;
samples_num = length(x);
duration_sec = (samples_num - 1) * ts;
t = (0 : samples_num - 1) * ts;             

figure;
plot(t, x, 'LineWidth', 0.5);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recorded Voice Signal Amplitude over Time');
xlim([0, duration_sec]);
grid on;

sound(x, fs);                             
audiowrite('x.wav', x, fs);      

%% Problem 4-3: Testing the speed control function
x = 'x.wav';

disp('Test: Speed = 0.5x');
p4_3(x , 0.5);
pause(duration_sec/0.5);

disp('Test: Speed = 1.5x');
p4_3(x , 1.5);
pause(duration_sec/1.5);

disp('Test: Speed = 2x');
p4_3(x , 2.0);
pause(duration_sec/2);

disp('Test: invalid speed = 1.12')
p4_3(x , 1.12);
