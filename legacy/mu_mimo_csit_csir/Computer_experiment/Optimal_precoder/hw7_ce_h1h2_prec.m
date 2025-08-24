clear; clc; close all;

% === Channel Setup ===
Nt = 2; Nr = 2;
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];
H2 = [0.3*exp(1j*pi/4),   0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];
H_all = cat(3, H1, H2);
U_set = [1, 2];   % subset of interest

snr_db = [10, 5, 2];
snr_lin_full = 10.^(snr_db / 10);            
snr_lin = snr_lin_full(U_set);  % [snr0, snr1]
I = eye(Nr);
P = Nt;

% === Prepare channel input for iterative waterfilling ===
H_sub = H_all(:, :, 1:2);  % H1, H2
[~, Cov] = iterative_waterfill(H_sub, P, 100);

% === Normalize Q_k to Frobenius norm Nt^2 ===
for k = 1:2
    Q = Cov(:,:,k);
    norm_sq = norm(Q, 'fro')^2;
    Cov(:,:,k) = Q * sqrt(Nt^2 / norm_sq);
end

% === Compute individual and corner rates ===
C0_opt = real(log2(det(I + (snr_lin(1)/Nt) * H1 * Cov(:,:,1) * H1')));
C1_opt = real(log2(det(I + (snr_lin(2)/Nt) * H2 * Cov(:,:,2) * H2')));
Csum_opt = real(log2(det(I + ...
    (snr_lin(1)/Nt) * H1 * Cov(:,:,1) * H1' + ...
    (snr_lin(2)/Nt) * H2 * Cov(:,:,2) * H2')));

% === Corner points ===
corner0 = [C0_opt, Csum_opt - C0_opt];  % decode user 0 first
corner1 = [Csum_opt - C1_opt, C1_opt];  % decode user 1 first

x_poly = [0, 0, corner1(1), corner0(1), C0_opt];
y_poly = [0, C1_opt, corner1(2), corner0(2), 0];

% === Plotting ===
figure; hold on; grid on;

fill([0 x_poly], [0 y_poly], [0.5 0.7 1], ...
    'EdgeColor', 'b', 'LineWidth', 1.8, 'FaceAlpha', 0.5);

plot(corner0(1), corner0(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner1(1), corner1(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

text(corner0(1)+0.1, corner0(2), ...
    sprintf('(%.2f, %.2f)', corner0(1), corner0(2)), 'FontSize', 10, 'Color', 'r');
text(corner1(1)+0.1, corner1(2), ...
    sprintf('(%.2f, %.2f)', corner1(1), corner1(2)), 'FontSize', 10, 'Color', 'b');
text(0.5, max(C0_opt, C1_opt)+0.4, ...
    sprintf('Sum Rate = %.2f bps/Hz', Csum_opt), 'FontSize', 11, 'FontWeight', 'bold');

xlabel('R_0 / B (bps/Hz)');
ylabel('R_1 / B (bps/Hz)');
title('MAC Capacity Region with Optimal Precoder (H1, H2)');
axis square; xlim([0 6]); ylim([0 6]);
legend({'Optimal Precoder Region', 'Corner 0', 'Corner 1'}, 'Location', 'Northeast');

% Save figure
print(gcf, 'fig/hw7_mac_precoder_region_h1h2.eps', '-depsc2');
