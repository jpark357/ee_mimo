clear; clc; close all;

% System parameters
Nt = 2;    % BS antennas
U = 2;     % number of users
snr_dB = linspace(-10, 25, 100);
snr_lin = 10.^(snr_dB / 10);
num_trials = 500;

% SNR offset: user 1 is 3 dB stronger
snr_offset_dB = [0, 3];
snr_offset_lin = 10.^(snr_offset_dB / 10);

% Store results
sum_capacity = zeros(size(snr_dB));

% === Main loop ===
for i = 1:length(snr_dB)
    C_trials = zeros(1, num_trials);
    for t = 1:num_trials
        % Random uplink user channels: Nt x 1 (dual MAC form)
        h0 = (randn(Nt, 1) + 1j*randn(Nt, 1)) / sqrt(2);
        h1 = (randn(Nt, 1) + 1j*randn(Nt, 1)) / sqrt(2);

        snr0 = snr_lin(i) * snr_offset_lin(1);
        snr1 = snr_lin(i) * snr_offset_lin(2);

        I = eye(Nt);

        % === Case 1: User 0 decoded first ===
        obj1 = @(alpha) -real(log2(det(I + ...
            alpha * snr0 * (h0 * h0') + ...
            (1 - alpha) * snr1 * (h1 * h1'))));
        alpha1 = fmincon(obj1, 0.5, [], [], [], [], 0, 1, [], ...
            optimoptions('fmincon','Display','off'));
        cap1 = -obj1(alpha1);

        % === Case 2: User 1 decoded first ===
        % obj2 = @(beta) -real(log2(det(I + ...
        %     beta * snr1 * (h1 * h1') + ...
        %     (1 - beta) * snr0 * (h0 * h0'))));
        % beta2 = fmincon(obj2, 0.5, [], [], [], [], 0, 1, [], ...
        %     optimoptions('fmincon','Display','off'));
        % cap2 = -obj2(beta2);

        % Choose the better one
        % C_trials(t) = max(cap1, cap2);    //same result
        C_trials(t) = cap1;
    end
    sum_capacity(i) = mean(C_trials);
end

% === Plot ===
figure;
plot(snr_dB, sum_capacity, 'b-', 'LineWidth', 1.8);
xlabel('SNR (dB)');
ylabel('Ergodic Sum Capacity [bps/Hz]');
title('Ergodic Sum Capacity vs. SNR');
grid on;
xlim([-10 25]); ylim([0 30]);
legend('N_{t}=2, U=2, N_{r}=1', 'Location', 'NorthWest');

% Save EPS
print('-depsc2', 'fig/hw8_42.eps');
