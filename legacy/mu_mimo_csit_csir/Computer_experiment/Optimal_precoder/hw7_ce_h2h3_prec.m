clear; clc; close all;

% === Channel matrices ===
H2 = [0.3*exp(1j*pi/4), 0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];
H3 = [exp(1j*pi/4), 1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3), 1.1*exp(1j*2*pi/5)];
H = cat(3, H2, H3);

% === SNR settings ===
snr1 = 10^(5/10);  % 5 dB
snr2 = 10^(2/10);  % 2 dB
Nt = 2;
I = eye(2);

% === Optimal precoder via iterative waterfilling ===
[~, Cov] = iterative_waterfill(H, Nt, 100);

% Normalize Frobenius norm to Nt^2
for k = 1:2
    Q = Cov(:,:,k);
    norm_sq = norm(Q, 'fro')^2;
    Cov(:,:,k) = Q * sqrt(Nt^2 / norm_sq);
end

% === Compute corner rates ===
C1_opt = real(log2(det(I + (snr1/2) * H2 * Cov(:,:,1) * H2')));
C2_opt = real(log2(det(I + (snr2/2) * H3 * Cov(:,:,2) * H3')));
Csum_opt = real(log2(det(I + (snr1/2) * H2 * Cov(:,:,1) * H2' + ...
                             (snr2/2) * H3 * Cov(:,:,2) * H3')));

corner0_opt = [C1_opt, Csum_opt - C1_opt];
corner1_opt = [Csum_opt - C2_opt, C2_opt];
x_opt = [0, 0, corner1_opt(1), corner0_opt(1), C1_opt];
y_opt = [0, C2_opt, corner1_opt(2), corner0_opt(2), 0];

% === Plot optimal precoder region only ===
figure; hold on; grid on;

fill([0 x_opt], [0 y_opt], [0.5 0.7 1], ...
    'EdgeColor', 'b', 'LineWidth', 1.8, 'FaceAlpha', 0.5);

% Corner points
plot(corner0_opt(1), corner0_opt(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner1_opt(1), corner1_opt(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

% Text annotations
text(corner0_opt(1) + 0.1, corner0_opt(2), ...
    sprintf('(%.2f, %.2f)', corner0_opt(1), corner0_opt(2)), 'FontSize', 10, 'Color', 'r');
text(corner1_opt(1) + 0.1, corner1_opt(2), ...
    sprintf('(%.2f, %.2f)', corner1_opt(1), corner1_opt(2)), 'FontSize', 10, 'Color', 'b');
text(0.5, max(C1_opt, C2_opt) + 0.4, ...
    sprintf('Sum Rate = %.2f bps/Hz', Csum_opt), 'FontSize', 11, 'FontWeight', 'bold');

% Labels and settings
xlabel('R_1 / B (bps/Hz)');
ylabel('R_2 / B (bps/Hz)');
title('MAC Capacity Region with Optimal Precoder (H2, H3)');
axis square; xlim([0 6]); ylim([0 6]);
legend({'Optimal Precoder Region', 'Corner 0', 'Corner 1'}, 'Location', 'Northeast');

% Save EPS for Overleaf
print(gcf, 'fig/hw7_mac_precoder_region_h2h3.eps', '-depsc2');
