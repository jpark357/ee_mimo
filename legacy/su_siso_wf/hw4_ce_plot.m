% AWGN capacity reference
C_awgn = log2(1 + 10.^(snr_dB / 10));
sum_mi_awgn = C_awgn * (K + L);  % AWGN upper bound for sum mutual info

%% Figure 1: Sum Mutual Information
figure(1); clf;
plot(snr_dB, sum_mi_vec_wf, '-o', 'LineWidth', 1.5); hold on;
plot(snr_dB, sum_mi_circ, '-s', 'LineWidth', 1.5);
plot(snr_dB, sum_mi_equal, '-d', 'LineWidth', 1.5);
plot(snr_dB, sum_mi_awgn, 'k--', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');
legend('Vector + WF', 'OFDM + WF', 'OFDM (no WF)', 'AWGN Capacity', ...
       'Location', 'NorthWest');
grid on;

%% Figure 2: Normalized Spectral Efficiency
figure(2); clf;
plot(snr_dB, spectral_eff_vec_wf, '-o', 'LineWidth', 1.5); hold on;
plot(snr_dB, spectral_eff_circ, '-s', 'LineWidth', 1.5);
plot(snr_dB, spectral_eff_equal, '-d', 'LineWidth', 1.5);
plot(snr_dB, C_awgn, 'k--', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
title('Normalized Spectral Efficiency vs. SNR', 'FontWeight','bold');
legend('Vector + WF', 'OFDM + WF', 'OFDM (no WF)', 'AWGN Capacity', ...
       'Location', 'NorthWest');
grid on;