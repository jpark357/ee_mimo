clc; clear; close all;

% Parameters
Na_list = 1:8;
SNR_dB_set = [0, 10, 20];
SNR_lin_set = 10.^(SNR_dB_set / 10);
num_trials = 1000;

capacity_noCSIT = zeros(length(SNR_dB_set), length(Na_list));
capacity_CSIT = zeros(length(SNR_dB_set), length(Na_list));

for s = 1:length(SNR_lin_set)
    SNR = SNR_lin_set(s);
    
    for idx = 1:length(Na_list)
        Na = Na_list(idx);
        C_noCSIT_trials = zeros(num_trials, 1);
        C_CSIT_trials = zeros(num_trials, 1);
        
        for k = 1:num_trials
            H = (randn(Na, Na) + 1j*randn(Na, Na)) / sqrt(2);  % IID Rayleigh
            HH = H' * H;
            lambda = sort(real(eig(HH)), 'descend');  % descending order
            lambda_avg = mean(lambda);

            % (a) No CSIT
            C_noCSIT_trials(k) = sum(log2(1 + (SNR / Na) * lambda));

            
            
            % (b) With CSIT: proper water-filling over eigenvalues
            % Water-filling level: find mu such that sum(max(mu - 1/gamma_j, 0)) = Ptotal
            % Equivalent to bisection

            inv_snr_lambda = (Na ./ (SNR * lambda));        
            Ptotal = Na;
            mu_low = inv_snr_lambda(1);
            mu_high = mu_low + Ptotal;
            tol = 1e-6;

            while (mu_high - mu_low) > tol
                mu = (mu_low + mu_high) / 2;
                p = max(mu - inv_snr_lambda, 0);
                if sum(p) > Ptotal
                    mu_high = mu;
                else
                    mu_low = mu;
                end
            end
            p_opt = max((mu - inv_snr_lambda), 0);
            C_CSIT_trials(k) = sum(log2(1 + (SNR / Na) * lambda .* p_opt));
        end

        % Averages
        capacity_noCSIT(s, idx) = mean(C_noCSIT_trials);
        capacity_CSIT(s, idx) = mean(C_CSIT_trials);
    end
end

% Plot
figure; hold on;
colors = lines(length(SNR_dB_set));
for s = 1:length(SNR_dB_set)
    plot(Na_list, capacity_noCSIT(s, :), '--', 'LineWidth', 1.5, 'Color', colors(s, :));
    plot(Na_list, capacity_CSIT(s, :), '-', 'LineWidth', 1.5, 'Color', colors(s, :));
end
xlabel('Number of Antennas N_a');
ylabel('Capacity (bps/Hz)');
title('MIMO Capacity with/without CSIT');
legend('No CSIT 0 dB','CSIT 0 dB','No CSIT 10 dB','CSIT 10 dB','No CSIT 20 dB','CSIT 20 dB',...
    'Location','northwest');
grid on;

% Save EPS for Overleaf
print(gcf, '5_25_ab', '-depsc2');
