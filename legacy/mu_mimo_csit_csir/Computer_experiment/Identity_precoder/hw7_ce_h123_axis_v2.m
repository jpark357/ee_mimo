clear; clc; close all;
% === Channel matrices ===
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];

H2 = [0.3*exp(1j*pi/4), 0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];

H3 = [exp(1j*pi/4), 1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3), 1.1*exp(1j*2*pi/5)];

% === SNR values ===
snr0 = 10;         % 10 dB
snr1 = 10^(5/10);  % ≈ 3.16
snr2 = 10^(2/10);  % ≈ 1.58

Nt = 2;  % Number of transmit antennas (fixed identity precoder assumed)
I = eye(Nt);
% === Total received signal covariance ===
H1_eff = (snr0 / Nt) * (H1 * H1');
H2_eff = (snr1 / Nt) * (H2 * H2');
H3_eff = (snr2 / Nt) * (H3 * H3');

% === Sum capacity
C_sum = real(log2(det(I + H1_eff + H2_eff + H3_eff)));

% === Polygon corner points ===
p000 = [0, 0, 0];

% XY plane (R0, R1)
p_xy_0 = [5.02, 0, 0];
p_xy_1 = [0, 1.91, 0];
p_xy_r = [5.02, 0.55, 0];  % corner0    sum = 5.58
p_xy_b = [3.66, 1.91, 0];  % corner1

% YZ plane (R1, R2)
p_yz_0 = [0, 1.91, 0];
p_yz_1 = [0, 0, 2.74];
p_yz_r = [0, 1.91, 1.82];  % corner2   sum = 3.73
p_yz_b = [0, 0.99, 2.74];  % corner3

% XZ plane (R0, R2)
p_xz_0 = [5.02, 0, 0];
p_xz_1 = [0, 0, 2.74];
p_xz_r = [5.02, 0, 1.06];  % corner1   sum = 6.08
p_xz_b = [3.34, 0, 2.74];  % corner3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% === Compute remaining z, x, y to make sum = C_sum
extra_z = C_sum - (p_xy_b(1) + p_xy_b(2));  % XY extending z
p3d_xy_r = [p_xy_r(1), p_xy_r(2), extra_z];
p3d_xy_b = [p_xy_b(1), p_xy_b(2), extra_z];

extra_x = C_sum - (p_yz_b(2) + p_yz_b(3));  % YZ extending x
p3d_yz_r = [extra_x, p_yz_r(2), p_yz_r(3)];
p3d_yz_b = [extra_x, p_yz_b(2), p_yz_b(3)];

extra_y = C_sum - (p_xz_b(1) + p_xz_b(3));  % XZ extending y
p3d_xz_r = [p_xz_r(1), extra_y, p_xz_r(3)];
p3d_xz_b = [p_xz_b(1), extra_y, p_xz_b(3)];




% === Start 3D plot ===
figure;hold on; grid on;
camzoom(0.7); 
% XY plane
fill3([p000(1), p_xy_1(1), p_xy_b(1), p_xy_r(1), p_xy_0(1)], ...
      [p000(2), p_xy_1(2), p_xy_b(2), p_xy_r(2), p_xy_0(2)], ...
      [p000(3), p_xy_1(3), p_xy_b(3), p_xy_r(3), p_xy_0(3)], ...
      [0.85 0.85 0.85], 'EdgeColor', 'k', 'LineWidth', 1.5);

% YZ plane
fill3([p000(1), p_yz_1(1), p_yz_b(1), p_yz_r(1), p_yz_0(1)], ...
      [p000(2), p_yz_1(2), p_yz_b(2), p_yz_r(2), p_yz_0(2)], ...
      [p000(3), p_yz_1(3), p_yz_b(3), p_yz_r(3), p_yz_0(3)], ...
      [0.7 0.85 1.0], 'EdgeColor', 'k', 'LineWidth', 1.5);

% XZ plane
fill3([p000(1), p_xz_1(1), p_xz_b(1), p_xz_r(1), p_xz_0(1)], ...
      [p000(2), p_xz_1(2), p_xz_b(2), p_xz_r(2), p_xz_0(2)], ...
      [p000(3), p_xz_1(3), p_xz_b(3), p_xz_r(3), p_xz_0(3)], ...
      [0.8 1.0 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);

% === Labels ===
xlabel('R_0 / B (bps/Hz)', 'FontSize', 12);
ylabel('R_1 / B (bps/Hz)', 'FontSize', 12);
zlabel('R_2 / B (bps/Hz)', 'FontSize', 12);
title('3D MU-MIMO MAC Capacity Region');

% === Axis settings: reverse x and y ===
xlim([0 6]); ylim([0 6]); zlim([0 6]);
axis vis3d;

set(gca, ...
    'XDir', 'reverse', ... % flip x
    'YDir', 'reverse', ... % flip y
    'BoxStyle', 'full', ...
    'XColor', 'k', 'YColor', 'k', 'ZColor', 'k');

% === View from front-top-right (origin is far back corner) ===
view([-45, 25]);

% === Save ===
print(gcf, 'fig/hw7_com_3d_h1h2h3.eps', '-depsc2');
