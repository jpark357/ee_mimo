clc; clear; close all;

% SNR values
snr0 = 10^(0/10);   % 1
snr1 = 10^(10/10);  % 10

% TDMA region
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);
Rprod_tdma = R0_tdma .* R1_tdma;
[~, idx_pf_tdma] = max(Rprod_tdma);
R0_pf_tdma = R0_tdma(idx_pf_tdma);
R1_pf_tdma = R1_tdma(idx_pf_tdma);

% FDMA region
alpha = linspace(0.01, 0.99, 1000);
R0_fdma = alpha .* log2(1 + snr0 ./ alpha);
R1_fdma = (1 - alpha) .* log2(1 + snr1 ./ (1 - alpha));
Rprod_fdma = R0_fdma .* R1_fdma;
[~, idx_pf_fdma] = max(Rprod_fdma);
R0_pf_fdma = R0_fdma(idx_pf_fdma);
R1_pf_fdma = R1_fdma(idx_pf_fdma);

% Plot
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2, 'DisplayName', 'TDMA'); hold on;
plot(R0_fdma, R1_fdma, 'r--', 'LineWidth', 2, 'DisplayName', 'FDMA');
plot(R0_pf_tdma, R1_pf_tdma, 'ko', 'MarkerSize', 8, 'DisplayName', 'PF Point (TDMA)');
plot(R0_pf_fdma, R1_pf_fdma, 'mo', 'MarkerSize', 8, 'DisplayName', 'PF Point (FDMA)');

xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Proportional Fair Points');
legend('Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save for Overleaf
drawnow;
print(gcf, '6_4ce_e', '-depsc2');

% Console output
fprintf('PF Point (TDMA): R0 = %.3f, R1 = %.3f, R0*R1 = %.3f\n', ...
        R0_pf_tdma, R1_pf_tdma, R0_pf_tdma * R1_pf_tdma);
fprintf('PF Point (FDMA): R0 = %.3f, R1 = %.3f, R0*R1 = %.3f\n', ...
        R0_pf_fdma, R1_pf_fdma, R0_pf_fdma * R1_pf_fdma);
