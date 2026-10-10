%% Init values
clc;
clear;
ts = 1e-9;
T = 1e-5;
tau = 1e-6;
t_len = round(T/ts);
tau_len = round(tau/ts);
t = (0 : t_len-1) * ts;

%% Problem 3-1: Transmitted signal generation
x = zeros(1, t_len);
x(1:tau_len) = 1;

figure;
plot(t, x, 'LineWidth', 1.5);
xlabel('Time (s)'); 
ylabel('x(t)');
title('Transmitted signal Generation');
xlim([0, T]);
ylim([-0.5, 1.5]);
grid on;

%% Problem 3-2: Received signal generation
R = 450;
C = 3e8;
alpha = 0.5;

td = 2 * R / C;
td_index = round(td / ts) + 1;

y = zeros(1, t_len);
y(td_index : td_index + tau_len - 1) = alpha;

figure;
plot(t, y, 'LineWidth', 1.5);
xlabel('Time (s)'); 
ylabel('y(t)');
title('Received Signal Generation');
xlim([0, T]);
ylim([-0.5, 1.5]);
grid on;

%% Problem 3-3: Distance Estimation using Template Matching

template = x(1:tau_len);
corr_len = t_len - tau_len + 1;
ro = zeros(1, corr_len);
for i=1:t_len-tau_len
    ro(i) = innerProduct(y(i:i+tau_len-1),template);
end
[value , index] = max(ro);
calc_td = (index - 1) * ts; 
calc_R = (calc_td * C) / 2;
    
disp(["Calculated td = " + calc_td; "Calculated Distance R = " + calc_R]); 
plot(ro);
function ro=innerProduct(a,b)
    ro= sum(a .* b);
end

%% Problem 3-4: Error Estimation
SIGMA = [0 0.001 0.01 0.1 1 2 3 4 5 10];
SIGMA_len = length(SIGMA);
results = zeros(1, SIGMA_len);
template = x(1 : tau_len);
corr_len = t_len - tau_len + 1;
TryItr = 100;

for i = 1 : SIGMA_len              
    errors = zeros(1, TryItr);
    for j = 1 : TryItr            
        noise = SIGMA(i) * randn(1, t_len);   
        z = y + noise;
        ro = zeros(1, corr_len);              
        
        for k = 1 : corr_len                  
            ro(k) = innerProduct(z(k : k+tau_len-1), template);
        end
        
        [value, index] = max(ro);
        calc_td = (index - 1) * ts;
        calc_R = calc_td * C / 2;             
        errors(j) = abs(R - calc_R);
    end
    results(i) = mean(errors);
end

figure;
semilogx(SIGMA, results, '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
hold on;
yline(10, 'r--', 'Threshold = 10m', 'LineWidth', 1.5);
xlabel('Noise Standard Deviation (\sigma)');
ylabel('Mean Estimation Error (m)');
title('Mean Distance Estimation Error vs Noise Level');
legend('Mean Error', '10m Threshold', 'Location', 'northwest');
grid on;