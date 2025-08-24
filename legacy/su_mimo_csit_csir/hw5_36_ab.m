% Problem 5.36 (a)+(b): Compare Large-Dim Approx ×4 vs. Monte Carlo (Nt = Nr = 4)

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

% ---------- Plot ----------
figure;
plot(snr_dB, capacity_iid, 'b-', 'LineWidth', 2); hold on;
plot(snr_dB, capacity_large_dim, 'r--', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Capacity [bps/Hz]');
title('Comparison of IID Capacity and Large-Dim Approx');
legend('IID Rayleigh (Monte Carlo)', 'Large-Dim Approx. for 4 x 4 MIMO', 'Location', 'SouthEast');
grid on;

% ---------- Save figure for Overleaf ----------
print(gcf, '5_36_ab', '-depsc2');  % generates fig5_36_ab_compare.eps
