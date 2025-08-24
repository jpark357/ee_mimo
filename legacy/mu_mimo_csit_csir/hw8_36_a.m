clear; clc; close all;

% Channel vectors
H0 = [0.3 - 1j, 0.7 + 1.2j];
H1 = [0.4j, 2 - 0.3j];
I = eye(2);

% Gram matrices
H0H0H = H0' * H0;
H1H1H = H1' * H1;

% SNR values
SNR0 = 10^(6/10);
SNR1 = 10^(10/10);

% === Optimization ===
sum_capacity_neg = @(alpha) -real(log2(det(I + ...
    alpha * SNR0 * H0H0H + (1 - alpha) * SNR1 * H1H1H)));

alpha0 = 0.5;
lb = 0.001;
ub = 0.999;

% Use fmincon
opt = optimoptions('fmincon', 'Display', 'off');
[alpha_opt, negCsum] = fmincon(sum_capacity_neg, alpha0, [], [], [], [], lb, ub, [], opt);
beta_opt = 1 - alpha_opt;
Csum_opt = -negCsum;

% Compute (R0, R1)
A = I + alpha_opt * SNR0 * H0H0H + beta_opt * SNR1 * H1H1H;
A1 = I + beta_opt * SNR1 * H1H1H;
C_total = real(log2(det(A)));
R1 = real(log2(det(A1)));
R0 = C_total - R1;

% === Plot BC Region and optimal point ===
alpha_vec = linspace(0.01, 0.99, 100);
point_list = [];

for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    corner0 = [C0, Csum - C0];
    corner1 = [Csum - C1, C1];

    point_list = [point_list;
        0, 0;
        0, C1;
        corner1;
        corner0;
        C0, 0];
end

% Convex hull
K = convhull(point_list(:,1), point_list(:,2));

% Plot
figure; hold on; grid on;

% Region
fill(point_list(K,1), point_list(K,2), [0.85 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% Convex hull outline
plot(point_list(K,1), point_list(K,2), 'k-', 'LineWidth', 2);

% Optimal point
plot(R0, R1, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(R0 + 0.1, R1, sprintf('Max Sum (%.2f, %.2f)', R0, R1), 'FontSize', 10, 'Color', 'r');

xlabel('R_0/B (bps/Hz)');
ylabel('R_1/B (bps/Hz)');
title('BC Capacity Region with Max Sum-Capacity Point');
legend('Region', 'Convex Hull', 'Max Sum Capacity', 'Location', 'SouthWest');
axis([0 4 0 6]);

% Save
print('-depsc2', 'fig/hw8_36_a.eps');
