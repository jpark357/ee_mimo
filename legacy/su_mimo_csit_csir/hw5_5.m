clc; clear;

% 1. Define channel matrix H
H = [1 + 0.5j, -0.6;
     0.2 + 1j, 0.4 + 0.1j];

% 2. Compute H^H * H
HHH = H' * H;

% 3. Eigen decomposition
[V, D] = eig(HHH);
lambda = diag(D);

% 4. Sort eigenvalues
[lambda_sorted, idx] = sort(lambda, 'descend');
lambda_max = lambda_sorted(1);
lambda_min = lambda_sorted(2);

% 5. Compute SNR threshold
snr_th = 1/lambda_min - 1/lambda_max;
snr_th_dB = 10 * log10(snr_th);

% 6. Compute beamforming vector
f = sqrt(2) * V(:, idx(1));

% 7. Define SNR range (dB and linear)
snr_dB = -10:0.1:20;
snr_lin = 10.^(snr_dB/10);

% 8. Capacity calculations
C_bf = log2(1 + snr_lin * lambda_max);                           % Beamforming (rank-1)
C_mux = log2(1 + snr_lin * lambda_max/2) + log2(1 + snr_lin * lambda_min/2);  % Spatial multiplexing (rank-2)

% 9. Plot
figure;
plot(snr_dB, C_bf, 'LineWidth', 2); hold on;
plot(snr_dB, C_mux, '--', 'LineWidth', 2);
xline(snr_th_dB, 'r:', 'LineWidth', 2);
legend('Beamforming (rank-1)', 'Spatial Multiplexing (rank-2)', sprintf('SNR_{th} ≈ %.2f dB', snr_th_dB));
xlabel('SNR (dB)');
ylabel('Capacity (bits/s/Hz)');
title('MIMO Capacity vs SNR');
grid on;
