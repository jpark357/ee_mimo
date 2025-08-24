clear; clc; close all;

% Parameters
Nt = 2;
Nr = 6;
U = 3;
SNR_dB = linspace(-10, 25, 100);
SNR_linear = 10.^(SNR_dB / 10);
num_trials = 1000;
snr_offset = [0, 5, 8];
snr_multiplier = 10.^(snr_offset / 10);

% Decoding orders
orders = {[1 2 3], [3 2 1]};
colors = ['b', 'g', 'r'];
labels = {'User 0', 'User 1', 'User 2'};

% Store results
user_rates = zeros(U, length(SNR_dB), 2); % (user, SNR, decoding order)

% Simulation for both decoding orders
for d = 1:2
    decode_order = orders{d};
    for i = 1:length(SNR_dB)
        Ru_temp = zeros(U, num_trials);
        for t = 1:num_trials
            H = cell(1,U);
            for u = 1:U
                H{u} = (randn(Nr, Nt) + 1j*randn(Nr, Nt)) / sqrt(2);
            end
            for idx = 1:U
                u = decode_order(idx);
                % Compute numerator and denominator matrices
                A = eye(Nr);
                B = eye(Nr);
                for v = idx:U
                    v_idx = decode_order(v);
                    snr_v = SNR_linear(i) * snr_multiplier(v_idx);
                    Hv = H{v_idx};
                    A = A + (snr_v / Nt) * (Hv * Hv');
                end
                for v = idx+1:U
                    v_idx = decode_order(v);
                    snr_v = SNR_linear(i) * snr_multiplier(v_idx);
                    Hv = H{v_idx};
                    B = B + (snr_v / Nt) * (Hv * Hv');
                end
                Ru_temp(u, t) = real(log2(det(A)) - log2(det(B)));
            end
        end
        user_rates(:, i, d) = mean(Ru_temp, 2);
    end
end

% Plotting
figure;
for d = 1:2
    subplot(1,2,d);
    hold on;
    for u = 1:U
        plot(SNR_dB, squeeze(user_rates(u,:,d)), 'Color', colors(u), 'LineWidth', 1.8);
        text(20, user_rates(u,end,d), labels{u}, 'FontSize', 10, 'Color', colors(u));
    end
    xlabel('SNR (dB)');
    ylabel('User Spectral Efficiency (bps/Hz)');
    title(['Decoding order: ',num2str(orders{d}-1)]);
    grid on; xlim([-10 25]);ylim([0 25]);
end

% Save EPS for Overleaf
print('-depsc2', 'fig/ex8_10_user_rates.eps');
