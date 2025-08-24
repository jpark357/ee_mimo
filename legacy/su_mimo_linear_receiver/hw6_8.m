clear; clc; close all;

% Parameters
Nt = 2; Nr = 2;
snr_dB = -10:1:25;
snr = 10.^(snr_dB/10);
lambda_rt = [1.7, 0.3];  % Eigenvalues of R_t
alpha_inv = 1.96;        % Diagonal element of R_t^{-1}
C_zf_opt = zeros(size(snr));
C_zf_nopre = zeros(size(snr));  % No precoding

for idx = 1:length(snr)
    snr_linear = snr(idx);
    total_len = Nt;
    total_power = Nt;

    % === ZF with Optimal Precoding ===
    inv_gain = Nt ./ (snr_linear .* lambda_rt);       
    [inv_sorted, sort_idx] = sort(inv_gain);           % Ascending order
    for m = total_len:-1:1
        inv_eta = (total_power + sum(inv_sorted(1:m))) / m;
        P_temp = inv_eta - inv_sorted(1:m);
        if all(P_temp >= 0)
            break;
        end
    end
    P = zeros(total_len, 1);
    P(sort_idx(1:m)) = P_temp;

    eta = (snr_linear .* P' .* lambda_rt) / Nt;
    valid_idx = eta > 0;
    eta_valid = eta(valid_idx);
    
    if isempty(eta_valid)
        C_zf_opt(idx) = 0;
    else
        term = exp(1 ./ eta_valid) .* expint(1 ./ eta_valid);
        C_zf_opt(idx) = log2(exp(1)) * sum(term);
    end

    % === ZF with No Precoding ===
    eta_nopre = snr_linear / (Nt * alpha_inv);  % eta = SNR / (2 * 1.96)
    C_zf_nopre(idx) = 2 * log2(exp(1)) * exp(1 / eta_nopre) * expint(1 / eta_nopre);
end

% === Plotting ===
figure;
plot(snr_dB, C_zf_opt, 'b-', 'LineWidth', 2); hold on;
plot(snr_dB, C_zf_nopre, 'r--', 'LineWidth', 2);
grid on;
xlabel('SNR [dB]');
ylabel('Ergodic ZF Spectral Efficiency (bps/Hz)');
xlim([-10 25]);
title('ZF Spectral Efficiency: Optimal Precoding vs No Precoding');
legend('Optimal Precoding', 'No Precoding', 'Location', 'NorthWest');

% Save for Overleaf
print(gcf, '6_8_ZF_with_precoding', '-depsc2');
