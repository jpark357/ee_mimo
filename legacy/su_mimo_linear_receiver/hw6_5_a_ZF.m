clc; clear; close all;

SNR_dB = -10:2:25;
SNR_lin = 10.^(SNR_dB / 10);
Nt_list = [1 2 4 8];
n_iter = 1000;

colors = lines(length(Nt_list));
Czf_per_ant = zeros(length(Nt_list), length(SNR_dB));

for idx = 1:length(Nt_list)
    Nt = Nt_list(idx);
    Nr = Nt;  % square MIMO
    Ns = Nt;
    
    for i = 1:length(SNR_lin)
        snr = SNR_lin(i);
        cap = zeros(n_iter, 1);
        for trial = 1:n_iter
            H = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);
            HHH_inv = inv(H' * H);
            diag_terms = real(diag(HHH_inv));
            cap(trial) = sum(log2(1 + (snr/Nt) * (1 ./ diag_terms)));
        end
        Czf_per_ant(idx, i) = mean(cap) / Nr;  % per antenna
    end
end

% Plot
figure;
for idx = 1:length(Nt_list)
    plot(SNR_dB, Czf_per_ant(idx, :), 'LineWidth', 2, 'DisplayName', sprintf('N_t = N_r = %d', Nt_list(idx)));
    hold on;
end
xlabel('SNR (dB)');
ylabel('ZF Spectral Efficiency per Antenna (bps/Hz)');
title('ZF Spectral Efficiency per Antenna vs. SNR');
grid on;
legend('Location', 'northwest');
xlim([-10 25]);

% Save
print(gcf, '6_5a_ZF_per_antenna', '-depsc2');
