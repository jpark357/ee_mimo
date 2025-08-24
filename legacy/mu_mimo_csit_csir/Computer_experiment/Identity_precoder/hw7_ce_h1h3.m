clear; clc; close all;

% === Channel matrices ===
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];

H3 = [exp(1j*pi/4),          1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3),     1.1*exp(1j*2*pi/5)];

% === SNR settings ===
snr1 = 10^(10/10);   % 10 dB ≈ 10
snr3 = 10^(2/10);    % 2 dB ≈ 1.58

% === Identity matrix ===
I = eye(2);

% === Individual capacities ===
C1 = real(log2(det(I + (snr1/2) * (H1 * H1'))));     % ≈ 5.02
C3 = real(log2(det(I + (snr3/2) * (H3 * H3'))));     % ≈ 2.74
Csum = real(log2(det(I + (snr1/2) * (H1 * H1') + (snr3/2) * (H3 * H3'))));  % ≈ 6.08

% === Corner points ===
corner1 = [C1, Csum - C1];   % User 1 decoded first
corner3 = [Csum - C3, C3];   % User 3 decoded first

% === Polygon vertices ===
x_poly = [0, 0, corner3(1), corner1(1), C1];
y_poly = [0, C3, corner3(2), corner1(2), 0];

% === Plot ===
figure; hold on; grid on;

% Fill region
fill([0 x_poly], [0 y_poly], [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% Corner points
plot(C1, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(0, C3, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner1(1), corner1(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner3(1), corner3(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

% Annotations
text(0.1, C3 + 0.1, sprintf('(%.2f, %.2f)', 0, C3), 'FontSize', 10);
text(corner3(1)+0.1, corner3(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner3(1), corner3(2), sum(corner3)), 'FontSize', 10, 'Color', 'b');
text(corner1(1)+0.1, corner1(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner1(1), corner1(2), sum(corner1)), 'FontSize', 10, 'Color', 'r');
text(C1 - 0.5, -0.4, sprintf('(%.2f, %.2f)', C1, 0), 'FontSize', 10);

% Labels
xlabel('R_1 / B (bps/Hz)');
ylabel('R_3 / B (bps/Hz)');
title('MU-MIMO MAC Capacity Region (H1, H3)');
xlim([0 6]); ylim([0 6]); axis square;

legend('Capacity Region', '(C_1, 0)', '(0, C_3)', 'Corner 1', 'Corner 3', ...
       'Location', 'northeast');

% Save EPS
print(gcf, 'fig/hw7_h1_h3.eps', '-depsc2');
