clc; clear; close all;

% SNRs
snr0 = 10^(0/10);   % 0 dB
snr1 = 10^(10/10);  % 10 dB

% TDMA Region
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% Prepare figure
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2); hold on;

% FDMA (BC): fix F0, vary E0/B
F0_vals = linspace(0.05, 0.95, 30);   % 적당한 샘플 수
E0_vals = linspace(0.01, 0.99, 200);  % 각 F0에 대해 정밀 sweep

for i = 1:length(F0_vals)
    F0 = F0_vals(i);
    F1 = 1 - F0;

    R0_line = zeros(1, length(E0_vals));
    R1_line = zeros(1, length(E0_vals));

    for j = 1:length(E0_vals)
        E0 = E0_vals(j);
        E1 = 1 - E0;

        % Spectral efficiencies per Eq (7.4)
        R0_line(j) = F0 * log2(1 + (E0 / F0) * snr0);
        R1_line(j) = F1 * log2(1 + (E1 / F1) * snr1);
    end

    % Draw smooth FDMA (BC) curve
    plot(R0_line, R1_line, 'r-', 'LineWidth', 0.5);
end

% Plot setup
xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Spectral Efficiency Regions: TDMA vs FDMA (BC)');
legend('TDMA', 'FDMA (BC)', 'Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save
print(gcf, '6_4ce_a_BC_fdma', '-depsc2');  % For Overleaf
