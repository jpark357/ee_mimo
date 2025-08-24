clc; clear; close all;

% Parameters
Nr = 3;
Nt = 1;
R_over_B = linspace(0.1, 4, 300);  % Spectral efficiency
SNR_dB_list = [10, 20, 30];
SNR_list = 10.^(SNR_dB_list / 10);

% Define PDF of gamma distribution (normalized)
f_xi = @(xi, Nr) (xi.^(Nr - 1) .* exp(-xi)) / gamma(Nr);

% Initialize storage for all SNRs
Pout_10dB = zeros(size(R_over_B));
Pout_20dB = zeros(size(R_over_B));
Pout_30dB = zeros(size(R_over_B));

% Loop over R/B to compute each Pout separately
for k = 1:length(R_over_B)
    r = R_over_B(k);

    % SNR = 10 dB
    upper10 = (2^r - 1) / SNR_list(1);
    Pout_10dB(k) = integral(@(xi) f_xi(xi, Nr), 0, upper10, 'AbsTol', 1e-14, 'RelTol', 1e-10);

    % SNR = 20 dB
    upper20 = (2^r - 1) / SNR_list(2);
    Pout_20dB(k) = integral(@(xi) f_xi(xi, Nr), 0, upper20, 'AbsTol', 1e-14, 'RelTol', 1e-10);

    % SNR = 30 dB
    upper30 = (2^r - 1) / SNR_list(3);
    Pout_30dB(k) = integral(@(xi) f_xi(xi, Nr), 0, upper30, 'AbsTol', 1e-14, 'RelTol', 1e-10);
end

% Plot all curves on the same figure
figure; hold on;
semilogy(R_over_B, Pout_10dB, 'b-', 'LineWidth', 1.5, 'DisplayName', 'SNR = 10 dB');
semilogy(R_over_B, Pout_20dB, 'r-', 'LineWidth', 1.5, 'DisplayName', 'SNR = 20 dB');
semilogy(R_over_B, Pout_30dB, 'g-', 'LineWidth', 1.5, 'DisplayName', 'SNR = 30 dB');

% Labels and styling
xlabel('R/B (bps/Hz)');
ylabel('P_{out}');
title('Outage Probability by SNR');
legend('Location', 'southwest');
grid on;
ylim([1e-14 1e-1]);
yticks(10.^(-14:-1));
xlim([0 4]);
set(gca, 'YScale', 'log') 
set(gca, 'FontSize', 12);

% Save EPS for Overleaf
print(gcf, '5_16_b', '-depsc2');
