% Parameters
snr_dB = 0:0.1:20;                      % SNR in dB
snr = 10.^(snr_dB / 10);                % Linear SNR

% Capacity per receive antenna
term1 = 2 * log2((1 + sqrt(1 + 4 * snr)) / 2);
term2 = (log2(exp(1)) ./ (4 * snr)) .* (sqrt(1 + 4 * snr) - 1).^2;
capacity_per_antenna = term1 - term2;

% Plot
figure;
plot(snr_dB, capacity_per_antenna, 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('Capacity per antenna [bits/s/Hz]');
title('Large-Dimensional MIMO Capacity per Antenna');

% Save EPS for Overleaf
print(gcf, '5_36_a', '-depsc2');