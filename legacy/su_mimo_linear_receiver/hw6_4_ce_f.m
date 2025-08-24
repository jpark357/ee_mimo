clc; clear; close all;

% SNR values
snr0 = 10^(0/10);
snr1 = 10^(10/10);

% TDMA
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% FDMA
alpha = linspace(0.01, 0.99, 1000);
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));

% Gradient for slope computation
dR0 = gradient(R0_fdma, alpha);
dR1 = gradient(R1_fdma, alpha);
slope = dR1 ./ dR0;

% Slope -1 point
[~, idx_slope1] = min(abs(slope + 1));
R0_m1 = R0_fdma(idx_slope1);
R1_m1 = R1_fdma(idx_slope1);

% Slope -3 point
[~, idx_slope3] = min(abs(slope + 3));
R0_m3 = R0_fdma(idx_slope3);
R1_m3 = R1_fdma(idx_slope3);

% Slope +1 point
[~, idx_p1] = min(abs(slope - 1));
R0_p1 = R0_fdma(idx_p1);
R1_p1 = R1_fdma(idx_p1);

% Tangent lines
x_line = linspace(0, 4, 100);
y_line_m1 = R1_m1 - (x_line - R0_m1);     % slope = -1
y_line_m3 = R1_m3 - 3 * (x_line - R0_m3); % slope = -3
y_line_p1 = R1_p1 + (x_line - R0_p1);     % slope = +1

% Plot region
figure;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2, 'DisplayName', 'FDMA Region'); hold on;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2, 'DisplayName', 'TDMA Region');

% Tangent points
plot(R0_m1, R1_m1, 'ko', 'MarkerSize', 7, 'DisplayName', 'Slope = -1');
plot(R0_m3, R1_m3, 'co', 'MarkerSize', 7, 'DisplayName', 'Slope = -3');
plot(R0_p1, R1_p1, 'go', 'MarkerSize', 7, 'DisplayName', 'Slope = +1');

% Tangent lines (dashed, color-coded)
plot(x_line, y_line_m1, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Tangent (Slope = -1)');
plot(x_line, y_line_m3, 'c--', 'LineWidth', 1.5, 'DisplayName', 'Tangent (Slope = -3)');
plot(x_line, y_line_p1, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Tangent (Slope = +1)');

xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Spectral Efficiency Regions with Slope-Based Tangents');
legend('Location', 'northeastoutside');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save
drawnow;
print(gcf, '6_4ce_tangents', '-depsc2');

% Output
fprintf('Slope = -1: R0 = %.3f, R1 = %.3f\n', R0_m1, R1_m1);
fprintf('Slope = -3: R0 = %.3f, R1 = %.3f\n', R0_m3, R1_m3);
fprintf('Slope = +1: R0 = %.3f, R1 = %.3f\n', R0_p1, R1_p1);
