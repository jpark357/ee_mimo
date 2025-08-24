
clc;


%% Parameters
L = 2;
K = 128;
total_len = K + L;
h = [0.16 + 0.26i, 0.55 + 0.09i, -0.67 - 0.39i];  % Channel taps h[0], h[1], h[2]
h_zp = [h, zeros(1, K - length(h))];              % Zero pad to length K
H_k = fft(h_zp);                                  % K-point DFT
H_gain = abs(H_k).^2;                             % |H[k]|^2

%% SNR sweep
snr_dB = -5:1:20;
sum_mi_equal = zeros(size(snr_dB));
spectral_eff_equal = zeros(size(snr_dB));

for idx = 1:length(snr_dB)
    SNR = 10^(snr_dB(idx)/10);

    % Equal power allocation: P[k] = 1 for all k
    sum_mi_equal(idx) = sum(log2(1 + SNR * H_gain));      % No waterfilling
    spectral_eff_equal(idx) = sum_mi_equal(idx) / (K + L);  % Normalize for CP overhead
end

%% Plot

% Plot
figure(5);
plot(snr_dB, sum_mi_equal, '-mo', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
legend('OFDM(no WF)', 'Location', 'NorthWest');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');

grid on;
figure(6);
plot(snr_dB, spectral_eff_equal, '-mo', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
legend('OFDM(no WF)', 'Location', 'NorthWest');
title('Normalized Spectral Efficiency vs. SNR', 'FontWeight','bold');
grid on;
