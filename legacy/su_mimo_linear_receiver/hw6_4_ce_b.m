clc; clear; close all;

% Given SNRs
snr0 = 10^(0/10);   % User 0: SNR = 0 dB = 1
snr1 = 10^(10/10);  % User 1: SNR = 10 dB = 10

% TDMA: time sharing
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% FDMA: bandwidth sharing
alpha = linspace(0.01, 0.99, 1000);  % avoid division by zero
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));

% Find equal rate points (R0 ≈ R1)
[~, idx_eq_tdma] = min(abs(R0_tdma - R1_tdma));
R0_eq_tdma = R0_tdma(idx_eq_tdma);
R1_eq_tdma = R1_tdma(idx_eq_tdma);

[~, idx_eq_fdma] = min(abs(R0_fdma - R1_fdma));
R0_eq_fdma = R0_fdma(idx_eq_fdma);
R1_eq_fdma = R1_fdma(idx_eq_fdma);

% Print numerical results
fprintf('Equal Rate Point (TDMA): R0 = %.3f, R1 = %.3f\n', R0_eq_tdma, R1_eq_tdma);
fprintf('Equal Rate Point (FDMA): R0 = %.3f, R1 = %.3f\n', R0_eq_fdma, R1_eq_fdma);

% Plot
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2,'DisplayName', 'TDMA'); hold on;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2 ,'DisplayName', 'FDMA');
plot(R0_eq_tdma, R1_eq_tdma, 'ko', 'MarkerSize', 8, 'DisplayName', 'Equal Rate (TDMA)');
plot(R0_eq_fdma, R1_eq_fdma, 'mo', 'MarkerSize', 8, 'DisplayName', 'Equal Rate (FDMA)');

% Unit-slope line (R1 = R0)
x_line = linspace(0, 1.5, 100);
plot(x_line, x_line, 'k--', 'LineWidth', 1.2, 'DisplayName', 'R_0 = R_1');

xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Equal Spectral Efficiency on TDMA and FDMA Regions');
legend('Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save for Overleaf
drawnow;
print(gcf, '6_4ce_b', '-depsc2');
