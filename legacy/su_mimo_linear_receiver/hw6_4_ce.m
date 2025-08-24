clc; clear; close all;
% unfaded SISO channel per each user
% Given SNRs
snr0 = 10^(0/10);   % User 0: SNR = 0 dB → 1
snr1 = 10^(10/10);  % User 1: SNR = 10 dB → 10

% TDMA: time sharing between users
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% FDMA: bandwidth sharing between users
alpha = linspace(0.01, 0.99, 1000);  % avoid division by zero
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));

% Plot
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2); hold on;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2);
xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');

title('Spectral Efficiency Regions: TDMA vs FDMA');
legend('TDMA Region', 'FDMA Region', 'Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save for Overleaf
print(gcf, '6_4ce_a', '-depsc2');

