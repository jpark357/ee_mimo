clc; clear; close all;

% SIMO parameters
Nt = 1;
Nr = 3;
R_over_B = linspace(0.1, 8, 300);
SNR_dB_list = [10, 20, 30];
SNR_list = 10.^(SNR_dB_list / 10);
log2SNR_list = log2(SNR_list);
logSNR_list = log(SNR_list);

% Define PDF of gamma distribution (normalized)
f_xi = @(xi, Nr) (xi.^(Nr - 1) .* exp(-xi)) / gamma(Nr);

% Initialize
norm_logPout = zeros(length(SNR_list), length(R_over_B));
norm_R = zeros(length(SNR_list), length(R_over_B));

% Compute normalized outage curves
for i = 1:length(SNR_list)
    SNR = SNR_list(i);
    log2SNR = log2(SNR);
    logSNR = log(SNR);
    for k = 1:length(R_over_B)
        r = R_over_B(k);
        upper = (2^r - 1) / SNR;
        val = integral(@(xi) f_xi(xi, Nr), 0, upper, 'AbsTol', 1e-14, 'RelTol', 1e-10);
        norm_logPout(i, k) = -log(val) / logSNR;
        norm_R(i, k) = r / log2SNR;
    end
end

% DMT line: d = Nr * (1 - r)
r_DMT = linspace(0, 1, 100);
d_DMT = Nr * (1 - r_DMT);

% Plot
figure; hold on;

% Outage curves
plot(norm_R(1,:), norm_logPout(1,:), 'Color', [1 0.5 0], 'LineWidth', 1.5, 'DisplayName', 'SNR = 10 dB');
plot(norm_R(2,:), norm_logPout(2,:), 'r-', 'LineWidth', 1.5, 'DisplayName', 'SNR = 20 dB');
plot(norm_R(3,:), norm_logPout(3,:), 'm-', 'LineWidth', 1.5, 'DisplayName', 'SNR = 30 dB');

% DMT line
plot(r_DMT, d_DMT, 'k--', 'LineWidth', 1.5, 'DisplayName', 'DMT');

% Axis and labels
xlabel('R/B / log2(SNR)');
ylabel('-log(P_{out}) / log(SNR)');
title('Outage Probability vs. DMT');
legend('Location', 'northeast');
xlim([0 2]);
ylim([0 8]);
grid on;
set(gca, 'FontSize', 12);

% Save EPS
print(gcf, '5_16_ac', '-depsc2');
