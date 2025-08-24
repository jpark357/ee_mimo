clc;clear all; close all;

% Parameters
Nt = 4; Nr = 4; Na = 4;                 % Square MIMO system
snr_dB = 0:0.1:20;
snr = 10.^(snr_dB / 10);
n_iter = 10000;

% ---------- (a) Large-Dimensional Approximation (scaled up by Nt = Nr = 4) ----------
term1 = 2 * log2((1 + sqrt(1 + 4 * snr)) / 2);
term2 = (log2(exp(1)) ./ (4 * snr)) .* (sqrt(1 + 4 * snr) - 1).^2;
capacity_large_dim = 4 * (term1 - term2);   % multiply by 4

% ---------- (b) Monte Carlo Simulation for IID Rayleigh (Nt = Nr = 4) ----------
capacity_iid = zeros(size(snr));
for i = 1:length(snr)
    cap_sum = 0;
    for k = 1:n_iter
        H = (randn(Nr, Nt) + 1j * randn(Nr, Nt)) / sqrt(2);
        HH = H * H';
        cap_sum = cap_sum + real(log2(det(eye(Nr) + (snr(i)/Nt) * HH)));
    end
    capacity_iid(i) = cap_sum / n_iter;
end

% ---------- (c) Monte Carlo Simulation for IND Rayleigh (Eq. 5.178, Xi = 0.4) ----------
Xi = 0.4;
Omega = (2 / (1 + Xi)) * [ ...
    1, Xi, 1, Xi;
    Xi, 1, Xi, 1;
    1, Xi, 1, Xi;
    Xi, 1, Xi, 1 ];
Omega_sqrt = sqrt(Omega);  % Element-wise square root

capacity_ind = zeros(size(snr));
for i = 1:length(snr)
    cap_sum = 0;
    for k = 1:n_iter
        H_w = (randn(Nr, Nt) + 1j * randn(Nr, Nt)) / sqrt(2);
        H_ind = Omega_sqrt .* H_w;  % Hadamard product
        HH = H_ind * H_ind';
        cap_sum = cap_sum + real(log2(det(eye(Nr) + (snr(i)/Nt) * HH)));
    end
    capacity_ind(i) = cap_sum / n_iter;
end

% ---------- Plot ----------
figure;
plot(snr_dB, capacity_large_dim, 'ro-');  hold on;
plot(snr_dB, capacity_iid, 'b-', 'LineWidth', 2); 
plot(snr_dB, capacity_ind, 'g-.', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Capacity [bps/Hz]');
title('IID, IND, and Large-Dimensional Capacity Comparison');
legend( 'Large-Dim Approx. for 4x4 MIMO','IID Rayleigh', 'IND Rayleigh (\Xi = 0.4)', 'Location', 'SouthEast');
grid on;

% ---------- Save figure for Overleaf ----------
print(gcf, '5_36_abc', '-depsc2');  % EPS output
