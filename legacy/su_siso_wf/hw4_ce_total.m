clear; clc;
L = 2;
K = 128;
N = K;             % Block length
total_len = K + L;
h = [0.16 + 0.26i, 0.55 + 0.09i, -0.67 - 0.39i];
h_rev = fliplr(h);
snr_dB = -5:1:20;
SNRs = 10.^(snr_dB/10);

%% Initialize outputs
sum_vec = zeros(size(snr_dB));
sum_circ = zeros(size(snr_dB));
sum_equal = zeros(size(snr_dB));
spectral_vec = zeros(size(snr_dB));
spectral_circ = zeros(size(snr_dB));
spectral_equal = zeros(size(snr_dB));
C_awgn = log2(1 + SNRs);

%% --- Vector Coding (Toeplitz + WF) ---
H_bar = zeros(N, N + L);
for n = 1:N
    for l = 0:L
        col = n + l;
        if col <= N + L
            H_bar(n, col) = h_rev(l + 1);
        end
    end
end
lambda_vec = svd(H_bar).^2;

%% --- OFDM (Circular Toeplitz + WF) ---
h_circ_padded = [h_rev, zeros(1, total_len - length(h))];
H_circ = zeros(total_len);
for row = 1:total_len
    H_circ(row, :) = circshift(h_circ_padded, [0, row - 1]);
end
lambda_circ = svd(H_circ).^2;

%% --- No WF (Uniform Power over OFDM Subcarriers) ---
h_zp = [h, zeros(1, K - length(h))];
H_fft = fft(h_zp);
H_gain = abs(H_fft).^2;

%% Sweep SNR
for idx = 1:length(SNRs)
    SNR = SNRs(idx);

    %--- Vector WF ---
    inv_gain = 1 ./ (SNR * lambda_vec);
    [inv_sorted, idx_sort] = sort(inv_gain);
    for m = K:-1:1
        inv_eta = (K + sum(inv_sorted(1:m))) / m;
        eta = 1 / inv_eta;
        P_temp = inv_eta - inv_sorted(1:m);
        if all(P_temp >= 0)
            P_sorted = zeros(K,1);
            P_sorted(1:m) = P_temp;
            break;
        end
    end
    P_vec = zeros(K,1);
    P_vec(idx_sort) = P_sorted;
    sum_vec(idx) = sum(log2(1 + SNR * lambda_vec .* P_vec));
    spectral_vec(idx) = sum_vec(idx) / (K + L);

    %--- Circular Toeplitz WF ---
    inv_gain_circ = 1 ./ (SNR * lambda_circ);
    [inv_sorted_c, idx_sort_c] = sort(inv_gain_circ);
    for m = total_len:-1:1
        inv_eta = (total_len + sum(inv_sorted_c(1:m))) / m;
        eta = 1 / inv_eta;
        P_temp = inv_eta - inv_sorted_c(1:m);
        if all(P_temp >= 0)
            P_sorted = zeros(total_len,1);
            P_sorted(1:m) = P_temp;
            break;
        end
    end
    P_circ = zeros(total_len,1);
    P_circ(idx_sort_c) = P_sorted;
    sum_circ(idx) = sum(log2(1 + SNR * lambda_circ .* P_circ));
    spectral_circ(idx) = sum_circ(idx) / (K + L);

    %--- Equal Power ---
    sum_equal(idx) = sum(log2(1 + SNR * H_gain));
    spectral_equal(idx) = sum_equal(idx) / (K + L);
end

%% Plot 1: Sum Mutual Information
figure;
plot(snr_dB, sum_vec, '-o', 'LineWidth', 1.5); hold on;
plot(snr_dB, sum_circ, '-s', 'LineWidth', 1.5);
plot(snr_dB, sum_equal, '-d', 'LineWidth', 1.5);
plot(snr_dB, C_awgn * (K + L), 'k--', 'LineWidth', 1.5);
legend('Vector + WF', 'OFDM + WF', 'No WF (Uniform Power)', 'AWGN Capacity', 'Location', 'NorthWest');
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');
grid on;

%% Plot 2: Spectral Efficiency
figure;
plot(snr_dB, spectral_vec, '-o', 'LineWidth', 1.5); hold on;
plot(snr_dB, spectral_circ, '-s', 'LineWidth', 1.5);
plot(snr_dB, spectral_equal, '-d', 'LineWidth', 1.5);
plot(snr_dB, C_awgn, 'k--', 'LineWidth', 1.5);
legend('Vector + WF', 'OFDM + WF', 'No WF (Uniform Power)', 'AWGN Capacity', 'Location', 'NorthWest');
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
title('Spectral Efficiency vs. SNR', 'FontWeight','bold');
grid on;