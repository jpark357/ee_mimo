clear; clc; close all;

% === Channel matrices (from Example 8.2)
H0 = [1 + 0.5j, 2;
      0.3 - 1j, 0.7 + 1.2j];

H1 = [0 + 0.4j, 2 + 0.3j;
      1.1 + 1j, 1.2];

% === SNR settings
snr0 = 10;               % 10 dB
snr1 = 10^(3/10);        % 3 dB ≈ 2

% === Compute MIMO individual capacities
C0 = log2(real(det(eye(2) + (snr0/2) * (H0 * H0'))));   % ≈ 8.5
C1 = log2(real(det(eye(2) + (snr1/2) * (H1 * H1'))));   % ≈ 4.0
Csum = 9.0;  % Given in example

% === Corner points
corner1 = [Csum - C1, C1];    % (5.0, 4.0)
corner0 = [C0, Csum - C0];    % (8.5, 0.5)

% === MAC capacity region polygon vertices (starting from origin)
x_poly = [0, 0, corner1(1), corner0(1), C0];
y_poly = [0, C1, corner1(2), corner0(2), 0];

% === Plot: MAC capacity region
figure; hold on; grid on;
fill(x_poly, y_poly, [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 2);

% === Plot MAC corner points
plot(0, C1, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      % (0, C1)
plot(C0, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      % (C0, 0)
plot(corner0(1), corner0(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);  % corner0
plot(corner1(1), corner1(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);  % corner1

% === Label each key point with numerical coordinates
text(0.2, C1 + 0.2, sprintf('(%.1f, %.1f)', 0, C1), 'FontSize', 10);
text(corner1(1)+0.2, corner1(2), sprintf('(%.1f, %.1f)', corner1(1), corner1(2)), 'FontSize', 10);
text(corner0(1)+0.2, corner0(2), sprintf('(%.1f, %.1f)', corner0(1), corner0(2)), 'FontSize', 10);
text(C0 + 0.1, -0.4, sprintf('(%.1f, %.1f)', C0, 0), 'FontSize', 10);

% === TDMA (MIMO) Line: vary tau from 0 to 1
tau = linspace(0, 1, 100);
R0_tdma = tau * C0;
R1_tdma = (1 - tau) * C1;

% === Fill TDMA region in light blue
tdma_x = [0, 0, C0];
tdma_y = [0, C1, 0];
fill(tdma_x, tdma_y, [0.8 0.9 1], 'EdgeColor', 'none');  % light blue fill

% === Plot TDMA line (MIMO-based)
plot(R0_tdma, R1_tdma, 'm--', 'LineWidth', 2);
text(2.0, 2.0, 'TDMA (SU-MIMO)', 'Color', 'm', 'FontSize', 10);



% --- Weighted sum-rate line (slope = -1/3) ---
% Line with slope -1/3 passing through (0, C1)
x_line = linspace(0, C0, 100);
y_line = - (1/3) * x_line + C1;

% Plot black dashed line (weighted sum-rate)
plot(x_line, y_line, 'k--', 'LineWidth', 2);
text(4.0, 3, 'Weighted sum-rate line (slope = -1/3)', ...
    'Color', 'k', 'FontSize', 10);

% Mark intersection point with TDMA (tau = 0 → (0, C1))
plot(0, C1, 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'k');
%text(0.2, C1 - 0.4, sprintf('(%.1f, %.1f)', 0, C1), 'Color', 'k', 'FontSize', 10);
% === Axes settings
xlabel('R_0 / B (b/s/Hz)', 'FontSize', 12);
ylabel('R_1 / B (b/s/Hz)', 'FontSize', 12);
title('MAC Capacity Region(MU-MIMO vs SU-MIMO TDMA)', 'FontSize', 13);
xlim([0 10]);
ylim([0 10]);

legend('MU-MIMO', '(0, C_1)', '(C_0, 0)', 'Corner 0', 'Corner 1', ...
       'TDMA (SU-MIMO)', 'Location', 'NorthEast');

% === Save for Overleaf
print(gcf, '8_2_MU_MIMO_SU_MIMO_TDMA', '-depsc2');
