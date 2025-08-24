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

fprintf('Total MAC sum rate (bps/Hz): %.4f\n', C_sum);

I = eye(2);

% === Case 1: user 0 decoded last ===
R12 = log2(real(det(I + A1 + A2 + A3)));
R1  = log2(real(det(I + A2 + A3)));
r0 = R12 - R1;

% === Case 2: user 1 decoded last ===
R02 = log2(real(det(I + A1 + A2 + A3)));
R0  = log2(real(det(I + A1 + A3)));
r1 = R02 - R0;

% === Case 3: user 2 decoded last ===
R01 = log2(real(det(I + A1 + A2 + A3)));
R01_only = log2(real(det(I + A1 + A2)));
r2 = R01 - R01_only;

% === 3D corner points ===
pt0 = [r0, log2(real(det(I + A2))) - log2(real(det(I))), ...
            log2(real(det(I + A3))) - log2(real(det(I)))];  % Approx only

pt1 = [log2(real(det(I + A1))) - log2(real(det(I))), r1, ...
            log2(real(det(I + A3))) - log2(real(det(I)))];

pt2 = [log2(real(det(I + A1))) - log2(real(det(I))), ...
            log2(real(det(I + A2))) - log2(real(det(I))), r2];

% Optional: exact points with other users jointly decoded
corner0 = [r0, R1 - log2(real(det(I + A3))), log2(real(det(I + A3))) - log2(real(det(I)))];
corner1 = [R0 - log2(real(det(I + A3))), r1, log2(real(det(I + A3))) - log2(real(det(I)))];
corner2 = [R01_only - log2(real(det(I + A2))), log2(real(det(I + A2))) - log2(real(det(I))), r2];

% === Plot ===
figure;
hold on; grid on;

scatter3(corner0(1), corner0(2), corner0(3), 100, 'ro', 'filled');
scatter3(corner1(1), corner1(2), corner1(3), 100, 'go', 'filled');
scatter3(corner2(1), corner2(2), corner2(3), 100, 'bo', 'filled');

% Annotation
text(corner0(1), corner0(2), corner0(3)+0.2, sprintf('%.2f', sum(corner0)), 'Color', 'r', 'FontSize', 11);
text(corner1(1), corner1(2), corner1(3)+0.2, sprintf('%.2f', sum(corner1)), 'Color', 'g', 'FontSize', 11);
text(corner2(1), corner2(2), corner2(3)+0.2, sprintf('%.2f', sum(corner2)), 'Color', 'b', 'FontSize', 11);

xlabel('R_0 / B (bps/Hz)');
ylabel('R_1 / B (bps/Hz)');
zlabel('R_2 / B (bps/Hz)');
title('Sum Rate Maximizing Corner Points (SNR-scaled)');

xlim([0 6]); ylim([0 6]); zlim([0 6]);
axis vis3d;
view([-45, 25]);
