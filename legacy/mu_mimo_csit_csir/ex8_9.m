clear; clc; close all;

% Parameters
Nt = 2;
Nr = 6;
U = 3;
SNR_dB = linspace(-10, 25, 100);
SNR_linear = 10.^(SNR_dB / 10);
num_trials = 500;

% SNR scaling per user
snr_offset = [0, 5, 8]; % in dB
snr_multiplier = 10.^(snr_offset / 10); % linear scale

% Store results
sum_capacity = zeros(size(SNR_dB));

% Monte Carlo simulation
for i = 1:length(SNR_dB)
    C_temp = zeros(1, num_trials);
    for t = 1:num_trials
        Hsum = zeros(Nr, Nr);
        for u = 1:U
            Hu = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);  % IID Rayleigh
            snr_u = SNR_linear(i) * snr_multiplier(u);
            Hsum = Hsum + (snr_u / Nt) * (Hu * Hu');
        end
        C_temp(t) = real(log2(det(eye(Nr) + Hsum)));
    end
    sum_capacity(i) = mean(C_temp);
end

% Plotting
figure;
plot(SNR_dB, sum_capacity, 'b-', 'LineWidth', 1.8);
xlabel('SNR (dB)');
ylabel('Ergodic Sum Capacity [bps/Hz]');
title('MU-MIMO Ergodic Sum Capacity (Example 8.9)');
grid on;
xlim([-10 25]);
ylim([0 60]);

% Save EPS for Overleaf
print('-depsc2', 'fig/ex8_9.eps');
