clear; clc; close all;

% === Define channel matrices
H0 = [1 + 0.5j, 2;
      0.3 - 1j, 0.7 + 1.2j];

H1 = [0 + 0.4j, 2 + 0.3j;
      1.1 + 1j, 1.2];

H2 = [0.7, -1 + 0.9j;
      1.3j, 0];

HH_sum = H0 * H0' + H1 * H1' + H2 * H2';

% === Parameters
SNR_dB = linspace(0, 30, 300);
SNR = 10.^(SNR_dB / 10);
S_inf = 2;

% === Compute L_inf (power offset)
L_inf = 1 - 0.5 * log2(det(HH_sum));

% === Initialize
C_true = zeros(size(SNR));
C_high = zeros(size(SNR));

% === Loop to compute SE
for i = 1:length(SNR)
    C_true(i) = log2(det(eye(2) + (SNR(i)/2) * HH_sum));
    C_high(i) = S_inf * (log2(SNR(i)) - L_inf);
end

% === Plotting
figure;
plot(SNR_dB, C_true, 'b', 'LineWidth', 1.8); hold on;
plot(SNR_dB, C_high, 'r--', 'LineWidth', 1.8);
xlabel('SNR (dB)');
ylabel('Unprecoded sum spectral efficiency [bps/Hz]');
title('Sum Spectral Efficiency vs. SNR');
legend('Unprecoded sum spectral efficiency', 'High-SNR Expansion', 'Location', 'SouthEast');
grid on;
xlim([0 30]);

% === Save to EPS for Overleaf
print('-depsc2', 'fig/hw8_12b_sum_capacity.eps');
