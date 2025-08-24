clc; clear; close all;

SNR_dB = -10:2:25;
SNR_lin = 10.^(SNR_dB / 10);
Nt_list = [1 2 4 8];
n_iter = 1000;

Cmmse_per_ant = zeros(length(Nt_list), length(SNR_dB));

for idx = 1:length(Nt_list)
    Nt = Nt_list(idx);
    Nr = Nt;  % square MIMO
    Ns = Nt
    for i = 1:length(SNR_lin)
        snr = SNR_lin(i);
        cap = zeros(n_iter, 1);
        for trial = 1:n_iter
            H = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);
            Gram = H' * H;
            A = eye(Nt) + (snr / Nt) * Gram;
            mmse_diag = real(diag(inv(A)));
            cap(trial) = sum(log2(1 ./ mmse_diag));  % = log2(1 + SINR)
        end
        Cmmse_per_ant(idx, i) = mean(cap) / Nr;
    end
end

% Plot
figure;
colors = lines(length(Nt_list));
for idx = 1:length(Nt_list)
    plot(SNR_dB, Cmmse_per_ant(idx, :), 'LineWidth', 2, 'DisplayName', sprintf('N_t = N_r = %d', Nt_list(idx)));
    hold on;
end
xlabel('SNR (dB)');
ylabel('LMMSE Spectral Efficiency per Antenna (bps/Hz)');
title('LMMSE Spectral Efficiency vs. SNR');
grid on;
legend('Location', 'northwest');
xlim([-10 25]);

% Save for Overleaf
print(gcf, '6_5b_LMMSE_per_antenna', '-depsc2');
