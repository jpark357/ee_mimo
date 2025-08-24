clc; clear; close all;

% Parameters
Nt = 4; Nr = 4;
SNR_dB = -10:1:25;
SNR_linear = 10.^(SNR_dB / 10);
num_trials = 1000;

capacity_iid = zeros(size(SNR_dB));
capacity_corr = zeros(size(SNR_dB));

% Define receive correlation matrix Rr
Rr = zeros(Nr, Nr);
for i = 1:Nr
    for j = 1:Nr
        Rr(i,j) = exp(-0.05 * (i - j)^2);
    end
end
Rr_sqrt = sqrtm(Rr);  % Matrix square root Rr^(1/2)

for i = 1:length(SNR_dB)
    snr = SNR_linear(i);
    cap_iid = zeros(num_trials, 1);
    cap_corr = zeros(num_trials, 1);
    
    for k = 1:num_trials
        Hw = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);  % IID Rayleigh

        % (1) IID case
        H_iid = Hw;
        M1 = eye(Nr) + (snr / Nt) * H_iid * H_iid';
        cap_iid(k) = real(log2(det(M1)));

        % (2) Correlated receive case
        H_corr = Rr_sqrt * Hw;
        M2 = eye(Nr) + (snr / Nt) * H_corr * H_corr';
        cap_corr(k) = real(log2(det(M2)));
    end
    
    capacity_iid(i) = mean(cap_iid);
    capacity_corr(i) = mean(cap_corr);
end

% Plot
figure;
plot(SNR_dB, capacity_iid, 'b-', 'LineWidth', 1.5); hold on;
plot(SNR_dB, capacity_corr, 'r--', 'LineWidth', 1.5);
xlabel('SNR (dB)');
ylabel('Capacity (bps/Hz)');
title('MIMO Capacity (N_t = N_r = 4)');
legend('IID (no corr)', 'Receive antenna correlation', 'Location', 'northwest');
grid on;

% Save for Overleaf
print(gcf, '5_24_ab', '-depsc2');
