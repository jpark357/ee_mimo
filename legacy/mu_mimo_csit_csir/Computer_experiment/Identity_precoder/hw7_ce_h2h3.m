clear; clc; close all;

% === Channel matrices from the image ===
H2 = [0.3*exp(1j*pi/4),   0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];

H3 = [exp(1j*pi/4),          1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3),     1.1*exp(1j*2*pi/5)];

% === SNR settings ===
snr2 = 10^(5/10);   % 5 dB ≈ 3.16
snr3 = 10^(2/10);   % 2 dB ≈ 1.58

% === Identity matrix ===
I = eye(2);

% === Individual capacities ===
C2 = real(log2(det(I + (snr2/2) * (H2 * H2'))));    % 1.91
C3 = real(log2(det(I + (snr3/2) * (H3 * H3'))));    % 2.74
Csum = real(log2(det(I + (snr2/2) * (H2 * H2') + (snr3/2) * (H3 * H3'))));  %3.73

% === Corner points ===
corner2 = [C2, Csum - C2];  % user 2 decoded first
corner3 = [Csum - C3, C3];  % user 3 decoded first

% === Polygon vertices ===
x_poly = [0, 0, corner3(1), corner2(1), C2];
y_poly = [0, C3, corner3(2), corner2(2), 0];

% === Plot ===
figure; hold on; grid on;

% Fill region
fill([0 x_poly], [0 y_poly], [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% Corner points
plot(C2, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(0, C3, 'ks', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner2(1), corner2(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner3(1), corner3(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

% Annotations
text(0.1, C3 + 0.1, sprintf('(%.2f, %.2f)', 0, C3), 'FontSize', 10);
text(corner3(1)+0.1, corner3(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner3(1), corner3(2), sum(corner3)), 'FontSize', 10, 'Color', 'b');
text(corner2(1)+0.1, corner2(2), sprintf('(%.2f, %.2f)\nSum = %.2f', ...
     corner2(1), corner2(2), sum(corner2)), 'FontSize', 10, 'Color', 'r');
text(C2 - 0.5, -0.4, sprintf('(%.2f, %.2f)', C2, 0), 'FontSize', 10);

% Labels
xlabel('R_2 / B (bps/Hz)');
ylabel('R_3 / B (bps/Hz)');
title('MU-MIMO MAC Capacity Region (H2, H3)');
xlim([0 6]); ylim([0 6]);
axis square;

legend('Capacity Region', '(C_2, 0)', '(0, C_3)', 'Corner 2', 'Corner 3', ...
       'Location', 'Northeast');

% Save EPS for Overleaf
print(gcf, 'fig/hw7_com_h2_h3.eps', '-depsc2');
