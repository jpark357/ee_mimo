clear; clc; close all;

% Channel vectors
H0 = [1 + 0.5j; 0.3 - 1j];
H1 = [2 + 0.3j; 1.2];

% SNR values
snr0 = 10;
snr1 = 10^(5/10);  % ≈ 3.1623

% Identity matrix
I = eye(2);

% Capacity computations
C0 = log2(1 + snr0 * norm(H0)^2);         % ≈ 4.61
C1 = log2(1 + snr1 * norm(H1)^2);         % ≈ 4.21
Csum = log2(real(det(I + snr0 * (H0 * H0') + snr1 * (H1 * H1'))));  % ≈ 7.93

% Corner points
corner0 = [C0, Csum - C0];
corner1 = [Csum - C1, C1];

% Polygon vertices (starting from (0,0) clockwise)
x_poly = [0, 0, corner1(1), corner0(1), C0];
y_poly = [0, C1, corner1(2), corner0(2), 0];

% === Plot ===
figure; hold on; grid on;

% Fill region
fill([0 x_poly], [0 y_poly], [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% Plot key points
plot(C0, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      
plot(0, C1, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      
plot(corner0(1), corner0(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
plot(corner1(1), corner1(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);

% Annotate each point with numerical coordinates
text(0.1, C1 + 0.1, sprintf('(%.2f, %.2f)', 0, C1), 'FontSize', 10);
text(corner1(1)+0.1, corner1(2), sprintf('(%.2f, %.2f)', corner1(1), corner1(2)), 'FontSize', 10);
text(corner0(1)+0.1, corner0(2), sprintf('(%.2f, %.2f)', corner0(1), corner0(2)), 'FontSize', 10);
text(C0 - 0.5, -0.4, sprintf('(%.2f, %.2f)', C0, 0), 'FontSize', 10);

% Axis and labels
xlabel('R_0 / B (b/s/Hz)', 'FontSize', 12);
ylabel('R_1 / B (b/s/Hz)', 'FontSize', 12);
title('MU-SIMO MAC Capacity Region', 'FontSize', 13);
axis([0 C0+0.7 0 C1+0.7]);
xlim([0 5]);
ylim([0 5]);

legend('Capacity Region', '(C_0, 0)', '(0, C_1)', 'Corner 0', 'Corner 1', ...
       'Location', 'SouthWest');

% Save for Overleaf
print(gcf, '8_1_MU_SIMO_MAC', '-depsc2');