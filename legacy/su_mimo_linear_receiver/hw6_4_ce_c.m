clc; clear; close all;

% Given SNRs
snr0 = 10^(0/10);   % User 0: SNR = 0 dB = 1
snr1 = 10^(10/10);  % User 1: SNR = 10 dB = 10

% TDMA: time sharing between users
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% FDMA: bandwidth sharing between users
alpha = linspace(0.01, 0.99, 1000);  % avoid division by zero
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));

% ---------- SLOPE = -1 (FDMA) ----------
dR0_fdma = gradient(R0_fdma, alpha);
dR1_fdma = gradient(R1_fdma, alpha);
slope_fdma = dR1_fdma ./ dR0_fdma;
[~, idx_slope_fdma] = min(abs(slope_fdma + 1));
R0_slope_fdma = R0_fdma(idx_slope_fdma);
R1_slope_fdma = R1_fdma(idx_slope_fdma);

% FDMA (slope = -1)
x_tangent = linspace(0, 4, 100);
y_tangent_fdma = R1_slope_fdma - (x_tangent - R0_slope_fdma);

% ---------- TDMA (0, 3.5) ~ (3.5, 0) ----------
x_tangent_tdma = [0, 3.5];
y_tangent_tdma = [3.5, 0];
R0_slope_tdma = x_tangent_tdma(1);
R1_slope_tdma = y_tangent_tdma(1);

% ---------- Plot ----------
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2, 'DisplayName', 'TDMA Region'); hold on;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2, 'DisplayName', 'FDMA Region');


plot(R0_slope_fdma, R1_slope_fdma, 'gs', 'MarkerSize', 8, 'DisplayName', 'Slope = -1 (FDMA)');
plot(R0_slope_tdma, R1_slope_tdma, 'ms', 'MarkerSize', 8, 'DisplayName', 'Slope = -1 (TDMA)');
plot(x_tangent, y_tangent_fdma, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Tangent Line (FDMA)');
plot(x_tangent_tdma, y_tangent_tdma, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Tangent Line (TDMA)');


xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Sum spectral efficiency');
legend('Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save for Overleaf
drawnow;
print(gcf, '6_4ce_c', '-depsc2');


fprintf('Slope = -1 (FDMA): R0 = %.3f, R1 = %.3f\n', R0_slope_fdma, R1_slope_fdma);
fprintf('Slope = -1 (TDMA): R0 = %.1f, R1 = %.1f\n', R0_slope_tdma, R1_slope_tdma);
