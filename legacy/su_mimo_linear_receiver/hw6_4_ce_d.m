clc; clear; close all;

% Given SNRs
snr0 = 10^(0/10);   % User 0: SNR = 0 dB = 1
snr1 = 10^(10/10);  % User 1: SNR = 10 dB = 10

% TDMA region
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% FDMA region
alpha = linspace(0.01, 0.99, 1000);  % avoid division by zero
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));

% ---------- SLOPE = -3 (FDMA) ----------
dR0_fdma = gradient(R0_fdma, alpha);
dR1_fdma = gradient(R1_fdma, alpha);
slope_fdma = dR1_fdma ./ dR0_fdma;
[~, idx_slope3_fdma] = min(abs(slope_fdma + 3));
R0_slope3_fdma = R0_fdma(idx_slope3_fdma);
R1_slope3_fdma = R1_fdma(idx_slope3_fdma);

% FDMA tangent line (slope = -3)
x_tangent = linspace(0, 4, 100);
y_tangent_fdma = R1_slope3_fdma - 3 * (x_tangent - R0_slope3_fdma);

% ---------- TDMA (slope = -3 line through (0, 3.5)) ----------
R0_slope3_tdma = 0;
R1_slope3_tdma = 3.5;
y_tangent_tdma = R1_slope3_tdma - 3 * (x_tangent - R0_slope3_tdma);  % y - y0 = -3(x - x0)

% ---------- Plot ----------
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2, 'DisplayName', 'TDMA'); hold on;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2, 'DisplayName', 'FDMA');

% slope = -3 points and tangent lines
plot(R0_slope3_fdma, R1_slope3_fdma, 'co', 'MarkerSize', 8, 'DisplayName', 'Slope = -3 (FDMA)');
plot(R0_slope3_tdma, R1_slope3_tdma, 'mo', 'MarkerSize', 8, 'DisplayName', 'Slope = -3 (TDMA)');
plot(x_tangent, y_tangent_fdma, 'c--', 'LineWidth', 1.2, 'DisplayName', 'Tangent Line (FDMA, Slope=-3)');
plot(x_tangent, y_tangent_tdma, 'm--', 'LineWidth', 1.2, 'DisplayName', 'Tangent Line (TDMA, Slope=-3)');

xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Weighted Sum Spectral Efficiency');
legend('Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save for Overleaf
drawnow;
print(gcf, '6_4ce_d', '-depsc2');

% Print numerical result
fprintf('Slope = -3 (FDMA): R0 = %.3f, R1 = %.3f\n', R0_slope3_fdma, R1_slope3_fdma);
fprintf('Slope = -3 (TDMA): R0 = %.1f, R1 = %.1f (fixed point)\n', R0_slope3_tdma, R1_slope3_tdma);
