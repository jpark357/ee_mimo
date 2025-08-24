clc; clear; close all;

% SNRs
snr0 = 10^(0/10);   % 0 dB
snr1 = 10^(10/10);  % 10 dB

% TDMA region
tau = linspace(0, 1, 1000);
R0_tdma = tau * log2(1 + snr0);
R1_tdma = (1 - tau) * log2(1 + snr1);

% Prepare figure
figure;
plot(R0_tdma, R1_tdma, 'b-', 'LineWidth', 2); hold on;

% FDMA (BC): collect all (R0, R1) points
F0_vals = linspace(0.00, 0.95, 30);
E0_vals = linspace(0.01, 0.99, 200);

all_R0 = [];
all_R1 = [];

for i = 1:length(F0_vals)
    F0 = F0_vals(i);
    F1 = 1 - F0;

    for j = 1:length(E0_vals)
        E0 = E0_vals(j);
        E1 = 1 - E0;

        R0 = F0 * log2(1 + (E0 / F0) * snr0);
        R1 = F1 * log2(1 + (E1 / F1) * snr1);

        all_R0(end+1) = R0;
        all_R1(end+1) = R1;
    end
end

% Compute convex hull
R_all = [all_R0(:), all_R1(:)];
K = convhull(R_all);  % Indices of convex boundary

% Draw convex hull as red solid line
plot(R_all(K,1), R_all(K,2), 'r-', 'LineWidth', 2);

% Plot setup
xlabel('R_0/B (User 0 Spectral Efficiency)');
ylabel('R_1/B (User 1 Spectral Efficiency)');
title('Spectral Efficiency Regions: TDMA vs FDMA (BC)');
legend('TDMA', 'FDMA (BC, Convex Hull)', 'Location', 'northeast');
xlim([0 4]);
ylim([0 4]);
grid on;

% Save
print(gcf, '6_4ce_a_BC_fdma_convex', '-depsc2');  % For Overleaf
