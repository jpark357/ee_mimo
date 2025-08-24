
clc;


%% Parameters
L = 2;
K = 128;
total_len = K + L;
h = [0.16 + 0.26i, 0.55 + 0.09i, -0.67 - 0.39i];  % h[0], h[1], h[2]
h_rev = fliplr(h);  % [h2, h1, h0]

%% Step 1: Construct Circular Toeplitz Matrix (row 1 = [h2, h1, h0, 0,...])
h_padded = [h_rev, zeros(1, total_len - length(h))];  % Length K+L
H_circ = zeros(total_len, total_len);
for row = 1:total_len
    H_circ(row, :) = circshift(h_padded, [0, row - 1]);
end

%% Step 2: Get singular values (λₖ)
lambda = svd(H_circ).^2;

%% Step 3: SNR sweep
snr_dB = -5:1:20;
sum_mi_circ = zeros(size(snr_dB));
spectral_eff_circ = zeros(size(snr_dB));

for idx = 1:length(snr_dB)
    SNR = 10^(snr_dB(idx)/10);
    inv_gain = 1 ./ (SNR * lambda);

    % Waterfilling
    [inv_sorted, sort_idx] = sort(inv_gain);
    P_sorted = zeros(total_len, 1);

    for m = total_len:-1:1
        inv_eta = (total_len + sum(inv_sorted(1:m))) / m;
        eta = 1 / inv_eta;
        P_temp = inv_eta - inv_sorted(1:m);
        if all(P_temp >= 0)
            P_sorted(1:m) = P_temp;
            break;
        end
    end

    % Restore original order
    P_opt = zeros(total_len, 1);
    P_opt(sort_idx) = P_sorted;

    % Compute results
    sum_mi_circ(idx) = sum(log2(1 + SNR * lambda .* P_opt));
    spectral_eff_circ(idx) = sum_mi_circ(idx) / (K + L);  % Normalized
end

%% Step 4: Plot Spectral Efficiency

% Plot
figure(3);
plot(snr_dB, sum_mi_circ, '-ro', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
legend('OFDM(with WF)', 'Location', 'NorthWest');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');

grid on;
figure(4);
plot(snr_dB, spectral_eff_circ, '-ro', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
legend('OFDM(with WF)', 'Location', 'NorthWest');
title('Normalized Spectral Efficiency vs. SNR', 'FontWeight','bold');
grid on;
