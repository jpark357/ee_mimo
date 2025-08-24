
clc;


L = 2;
K = 128;
total_len = K + L;

snr_dB = -5:1:20;
SNR = 10.^(snr_dB / 10);
C_awgn = log2(1 + SNR);
sum_mi_awgn  = C_awgn * (K + L);     % Sum mutual information upper bound

figure(7);
plot(snr_dB, sum_mi_awgn , '-ko', 'LineWidth', 1.5); hold on;
legend('AWGN Capacity', 'Location', 'NorthWest');
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');

grid on;
figure(8);
plot(snr_dB, C_awgn, '-ko', 'LineWidth', 1.5); hold on;
legend('AWGN Capacity', 'Location', 'NorthWest');
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
title('Normalized Spectral Efficiency vs. SNR', 'FontWeight','bold');
grid on;


