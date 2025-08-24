clear; clc;
close all;

% Parameters
L = 2;
N = 128;           % Block length
K = N;             % Number of symbols (codeword length)
h = [0.16+0.26i, 0.55+0.09i, -0.67-0.39i];  % Channel taps
h_rev = fliplr(h);  % h(3), h(2), h(1)

% Construct Toeplitz channel matrix H_bar of size N x (N+L)
H_bar = zeros(N, N + L);
for n = 1:N
    for l = 0:L
        col = n + l;
        if col <= N + L
            H_bar(n, col) = h_rev(l + 1);  % reversed h assignment
        end
    end
end

% SVD of convolution matrix
[~, S, ~] = svd(H_bar);
lambda = diag(S).^2;  % Squared singular values (eigen- subchannel power gain)

% SNR range (dB)
snr_dB = -5:1:20;
spectral_eff_vec_wf = zeros(size(snr_dB));
sum_mi_vec_wf = zeros(size(snr_dB));

for idx = 1:length(snr_dB)
    SNR = 10^(snr_dB(idx)/10);
    inv_gain = 1 ./ (SNR * lambda);
    
    % Sort for waterfilling
    [inv_sorted, sort_idx] = sort(inv_gain);
    P_sorted = zeros(K, 1);
    
    % Waterfilling loop
    for m = K:-1:1
    inv_eta = ((K + L) + sum(inv_sorted(1:m))) / m;
    eta = 1 / inv_eta;
    P_temp = inv_eta - inv_sorted(1:m);
    if all(P_temp >= 0)
        P_sorted(1:m) = P_temp;
        break;
    end
end

    % Restore original order
    P_opt = zeros(K, 1);
    P_opt(sort_idx) = P_sorted;

    % Spectral efficiency using normalization (4.113)
    sum_mi_vec_wf(idx) = sum(log2(1 + SNR * lambda .* P_opt));
    % Spectral efficiency using normalization (4.113)
    spectral_eff_vec_wf(idx) = (1 / (K + L)) * sum(log2(1 + SNR * lambda .* P_opt));
end

% Plot
figure(1);
plot(snr_dB, sum_mi_vec_wf, '-o', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Sum Mutual Information (bits)', 'FontWeight','bold');
legend('Vector(with WF)', 'Location', 'NorthWest');
title('Sum Mutual Information vs. SNR', 'FontWeight','bold');
grid on;

figure(2);
plot(snr_dB, spectral_eff_vec_wf, '-o', 'LineWidth', 1.5);
xlabel('SNR (dB)', 'FontWeight','bold');
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontWeight','bold');
legend('Vector(with WF)', 'Location', 'NorthWest');
title('Normalized Spectral Efficiency vs. SNR', 'FontWeight','bold');
grid on;


