clear; clc; close all;

% === Channel matrices ===
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];

H2 = [0.3*exp(1j*pi/4), 0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];

% === SNR settings ===
snr0 = 10;               % 10 dB
snr1 = 10^(5/10);        % 5 dB ≈ 3.16

% === Identity matrix ===
I = eye(2);

% === Individual capacities ===
C0 = real(log2(det(I + (snr0/2) * (H1 * H1'))));        % ≈ 5.02
C1 = real(log2(det(I + (snr1/2) * (H2 * H2'))));        % ≈ 1.91
Csum = real(log2(det(I + (snr0/2) * (H1 * H1') + (snr1/2) * (H2 * H2'))));  % ≈ 5.58

% === Corner points ===
corner0 = [C0, Csum - C0];
corner1 = [Csum - C1, C1];

% === Polygon vertices ===
x_poly = [0, 0, corner1(1), corner0(1), C0];
y_poly = [0, C1, corner1(2), corner0(2), 0];

% === Plot ===
figure; hold on; grid on;

% Fill region
fill([0 x_poly], [0 y_poly], [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% Corner points
plot(C0, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(0, C1, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner0(1), corner0(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner1(1), corner1(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

% Annotations
text(0.1, C1 + 0.1, sprintf('(%.2f, %.2f)', 0, C1), 'FontSize', 10);
text(corner1(1)+0.1, corner1(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner1(1), corner1(2), sum(corner1)), 'FontSize', 10, 'Color', 'b');
text(corner0(1)+0.1, corner0(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner0(1), corner0(2), sum(corner0)), 'FontSize', 10, 'Color', 'r');
text(C0 - 0.5, -0.4, sprintf('(%.2f, %.2f)', C0, 0), 'FontSize', 10);

% Labels
xlabel('R_0 / B (bps/Hz)');
ylabel('R_1 / B (bps/Hz)');
title('MU-MIMO MAC Capacity Region (H1, H2)');
xlim([0 6]); ylim([0 6]);
axis square;

legend('Capacity Region', '(C_0, 0)', '(0, C_1)', 'Corner 0', 'Corner 1', ...
       'Location', 'Northeast');

% Save EPS for Overleaf
print(gcf, 'fig/hw7_com_h1_h2.eps', '-depsc2');
